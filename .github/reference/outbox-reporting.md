# Outbox & Reporting System Architecture

## Overview

The ezEdMed (EEM) system implements an **asynchronous job queue** and **reporting architecture** using the **Outbox** table as a centralized registry for deferred background tasks. This architecture enables resource-intensive operations (PDF generation, Excel exports, multi-user reports) to execute without blocking web request handlers, providing responsive user experience and efficient server resource utilization.

**Key Characteristics:**
- **Asynchronous Processing:** Report generation is deferred to background processes
- **User-Centric:** Each job is associated with a specific user and appears in their outbox
- **Duplicate Prevention:** Built-in logic prevents duplicate jobs from being queued
- **PHP Integration:** Uses PHP scripts with fpdf, PhpSpreadsheet, and PhpWord for document generation
- **Status Tracking:** Jobs progress through lifecycle: Pending → Processing → Completed/Failed
- **WEB_Outbox Folder:** Central file storage location for all generated reports

---

## System Components

### 1. Outbox Table (`[Outbox]`)

The Outbox table serves as the **job registry and status tracker** for all deferred background tasks.

**Key Fields:**
- `ID` (1): Primary key (auto-generated via `SqNo_SetRecordID`)
- `Created_Date` (2), `Created_Time` (3): Job creation timestamp
- `Modified_Date` (5), `Modified_Time` (6): Last modification timestamp
- `FileName` (7): User-friendly filename for the generated file
- `PathToFileOnServer` (8): Server-side path to generated file (uses `{outbox}` token)
- `Status` (9): Job lifecycle state: `"Pending"`, `"Completed"`, `"Failed"`, `"Aborted"`
- `CodeToExecute` (10): 4D method call string to generate the report
- `HideItemAfterDate` (11): Auto-cleanup date (defaults to Created_Date + 5 days)
- `User_Key` (12): Foreign key to `[Users]` table (which user requested the report)
- `Description` (14): Human-readable description of the job
- `TimeToExecute_in_ms` (15): Execution time in milliseconds (recorded on completion)
- `ResultFileSize` (16): File size in bytes (recorded on completion)
- `DelayUntil_DateTimeStamp` (17): Optional timestamp to delay processing (used for large jobs)
- `isClientSafe` (18): Boolean indicating if job can run on 4D Remote client

**Trigger Logic:**
```4d
If (Trigger event = On Saving New Record Event) | (Trigger event = On Saving Existing Record Event)
    If ([Outbox]ID = 0)
        SqNo_SetRecordID(->[Outbox])
        [Outbox]Created_Date := Current date
        [Outbox]Created_Time := Current time
    End if
    [Outbox]Modified_Date := Current date
    [Outbox]Modified_Time := Current time
    
    If ([Outbox]HideItemAfterDate = !00-00-00!)
        [Outbox]HideItemAfterDate := Add to date([Outbox]Created_Date; 0; 0; 5)  // Auto-hide after 5 days
    End if
End if

// Normalize path to use {outbox} token
If ([Outbox]PathToFileOnServer # "{outbox}@") & (Position("WEB_Outbox"; [Outbox]PathToFileOnServer) > 0)
    [Outbox]PathToFileOnServer := Replace string([Outbox]PathToFileOnServer; Folder separator; "/")
    $pos := Position("WEB_Outbox"; [Outbox]PathToFileOnServer) + Length("WEB_Outbox")
    [Outbox]PathToFileOnServer := "{outbox}" + Substring([Outbox]PathToFileOnServer; $pos)
End if
```

### 2. WEB_Outbox Folder

**Physical Location:**
- Root folder: `<database_root>/WEB_Outbox/`
- Subfolder: `WEB_Outbox/Eligibility Reports/` (for eligibility CSV files)

**Path Resolution:**
- The `{outbox}` token in `[Outbox]PathToFileOnServer` is expanded by the system
- Helper method: `Outbox_GetFolderPath` returns the platform-specific path to `WEB_Outbox/`
- Helper method: `Outbox_GetUniqueFileNameSegment` generates timestamp-based unique prefixes

**Example Paths:**
```
{outbox}/uid 123 1736183452 Therapist Caseload.pdf
{outbox}/u15 1736183890 goal planning sheet - Caseload.pdf
{outbox}/EligibilityReports.zip
{outbox}/Eligibility Reports/001 Eligibility Report 2024-12.csv
```

### 3. Background Processing Daemon

**Daemon Process:** `IH_WebShell_Daemon_Regular`

Called periodically by the main daemon to process queued jobs.

```4d
// IH_WebShell_Daemon_Regular (disable_background_updates)

Profiler_START(Current method name)

If (ds.Outbox.query("Status=:1"; "Pending").length > 0)
    Outbox_ProcessItems  // Trigger background processing
End if

If (Not($disable_background_updates))
    Files4Import_IMP_ProcessAll
    QueuedTasks_MonitorQueue
End if

Profiler_STOP(Current method name)
```

**Outbox_ProcessItems Method:**

This method spawns or wakes a dedicated background process (`"Outbox_ProcessItems"`) that:
1. Queries for pending jobs: `QUERY([Outbox]; [Outbox]Status="Pending")`
2. Orders by priority/ID
3. Executes `[Outbox]CodeToExecute` using `EXECUTE METHOD`
4. Updates status to `"Completed"` or `"Failed"`
5. Records execution time and file size
6. Loops until no pending jobs remain

**Process Isolation:**
- The `Outbox_ProcessItems` process runs independently from web request handlers
- Uses `Process number("Outbox_ProcessItems")` to check if already running
- Prevents duplicate spawning using process name checking

---

## Report Generation Flow

### End-to-End Pipeline (ASCII Diagram)

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                        USER INITIATES REPORT REQUEST                           │
└──────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│  STEP 1: Web Request Handler (e.g., waReports_DistrictCount)                 │
│  • Validates authorization (WEB_b_IsDistrictAdmin, WEB_b_IsSysAdmin, etc.)   │
│  • Parses request parameters (school year, district, report type)            │
│  • Determines report scope (single user vs. multi-user)                      │
└──────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│  STEP 2: Duplicate Check (Outbox_JobDoesNotExist)                            │
│  • Query: [Outbox]User_Key = WEB_l_UserID AND Status = "Pending"             │
│  • Check: Does [Outbox]CodeToExecute match job signature?                    │
│  • Result: Skip if duplicate, proceed if unique                              │
└──────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│  STEP 3: Job Creation (CREATE RECORD([Outbox]))                              │
│  • PathToFileOnServer := Outbox_GetFolderPath + unique filename              │
│  • Status := "Pending"                                                       │
│  • User_Key := WEB_l_UserID                                                  │
│  • FileName := "District Counts 2024.xls"  (user-friendly name)              │
│  • CodeToExecute := "Report_DollarsCounts_ToExcel (args...)"                 │
│  • Description := "Excel version of the 2024 District Counts report."       │
│  • isClientSafe := True (if report can run on remote client)                │
│  • DelayUntil_DateTimeStamp := future timestamp (optional, for large jobs)  │
│  • SAVE RECORD([Outbox])                                                     │
└──────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│  STEP 4: Trigger Processing (Outbox_ProcessItems)                            │
│  • Call Outbox_ProcessItems (spawns/wakes background process)                │
│  • OR: Wait for next daemon cycle (IH_WebShell_Daemon_Regular)               │
└──────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│  STEP 5: User Notification (WebAlert_AddHtmlMessage)                         │
│  • Success: "The District Counts report has been sent to your outbox."       │
│  • Include link: <a href="/outbox" target="_outbox_">View Outbox</a>        │
│  • User continues browsing (no waiting for report to complete)               │
└──────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│  STEP 6: Background Process Picks Up Job                                     │
│  • Process: "Outbox_ProcessItems" (dedicated background worker)              │
│  • Query: QUERY([Outbox]; [Outbox]Status = "Pending"; *)                     │
│  •        QUERY([Outbox]; & ; [Outbox]DelayUntil <= now)                     │
│  • Order: ORDER BY([Outbox]; [Outbox]ID; >)  (oldest first)                  │
└──────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│  STEP 7: Execute Report Generation Method                                    │
│  • Load [Outbox] record for processing                                       │
│  • [Outbox]Status := "Processing" (optional, for tracking)                   │
│  • EXECUTE METHOD([Outbox]CodeToExecute)                                     │
│  • Example: Report_DollarsCounts_ToExcel (reportType; districtID; ...)       │
└──────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│  STEP 8A: Data Collection & Preparation (4D Queries & Calculations)          │
│  • Query database for report data (treatments, students, users, etc.)        │
│  • Perform calculations (aggregations, counts, sums, date ranges)            │
│  • Format data for output (date strings, currency formatting)                │
│  • Build arrays or collections for template injection                        │
└──────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│  STEP 8B: PHP Template Loading & Injection                                   │
│  • Load PHP template: WebCache_GetTextOfFile("reports_phpScripts/xxx.php")  │
│  • Inject data: Replace "//%%PLACEHOLDER%%" with PHP array declarations     │
│  • Example: $rowArray[] = new RowData('John Doe', '01/15/2024', ...);       │
│  • Build complete PHP script with embedded data                              │
└──────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│  STEP 8C: PHP Execution (PDF/Excel/Word Generation)                          │
│  • Call: PHP_exec_dynamic_code($php_script)                                  │
│  • PHP uses fpdf (PDF), PhpSpreadsheet (Excel), or PhpWord (Word)            │
│  • Example (PDF): $pdf->AddPage(); $pdf->Cell(...); $pdf->Output('F', ...)  │
│  • Output file written to: [Outbox]PathToFileOnServer                        │
└──────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│  STEP 9: Post-Processing & Status Update                                     │
│  • Check: File_DoesExist([Outbox]PathToFileOnServer)                         │
│  • If success:                                                               │
│    - [Outbox]Status := "Completed"                                           │
│    - [Outbox]ResultFileSize := Get document size(...)                        │
│    - [Outbox]TimeToExecute_in_ms := $end_time - $start_time                  │
│  • If failure:                                                               │
│    - [Outbox]Status := "Failed"                                              │
│    - Log error details                                                       │
│  • SAVE RECORD([Outbox])                                                     │
│  • WebLog_UpdatePrintCount (increment usage statistics)                      │
└──────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│  STEP 10: User Downloads Report                                              │
│  • User navigates to /outbox page (waOutbox_ShowAll handler)                 │
│  • Page lists all user's outbox items (filtered by WEB_l_UserID)             │
│  • Status displayed: "Pending", "Completed", "Failed"                        │
│  • User clicks download link: /outbox/download?id=<OutboxID>                 │
│  • Handler: WebConnect_SendFileAsDownload([Outbox]PathToFileOnServer)        │
│  • Browser downloads file with [Outbox]FileName                              │
└──────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│  STEP 11: Optional Cleanup                                                   │
│  • Automatic: Jobs hidden after [Outbox]HideItemAfterDate (default 5 days)  │
│  • Manual: User can delete items via /outbox/delete endpoint                 │
│  • Periodic: Daemon may purge old completed jobs from database               │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## Common Report Types & Workflows

### 1. PHP-Based PDF Reports (fpdf)

**Use Case:** Therapist caseload reports, RFS reports, new eligibility lists

**Example: Therapist Caseload Report**

**Trigger:** `waReports_TherapistCaseLoad` → POST to `/reports/therapistCaseLoad`

**Job Creation:**
```4d
CREATE RECORD([Outbox])
[Outbox]PathToFileOnServer := Outbox_GetFolderPath + "uid 123 " + String(Milliseconds) + " Therapist Caseload.pdf"
[Outbox]Status := "Pending"
[Outbox]User_Key := WEB_l_UserID
[Outbox]FileName := "John Doe Caseload.pdf"
[Outbox]CodeToExecute := "Report_TherapistCaseLoad (123; \"" + [Outbox]PathToFileOnServer + "\")"
[Outbox]Description := "Therapist Caseload Report for John Doe."
[Outbox]isClientSafe := True
SAVE RECORD([Outbox])
Outbox_ProcessItems
```

**Report Generation Method (`Report_TherapistCaseLoad`):**
```4d
// 1. Query student data
QUERY([Student]; [Student]Therapist_UserID = $userID)
QUERY([Student]; [Student]isActive = True)

// 2. Build PHP data arrays
$php := "$tableRowArray = array();\r\n"
For ($i; 1; Records in selection([Student]))
    $php += "$tableRowArray[] = new RowData("
    $php += "'" + php_safeStr([Student]Full_Name) + "', "
    $php += "'" + php_safeStr(Date2String([Student]DOB; "mm/dd/yyyy")) + "', "
    $php += "'" + php_safeStr([Student]School_Name) + "');\r\n"
    NEXT RECORD([Student])
End for

// 3. Load PHP template and inject data
$template := WebCache_GetTextOfFile("reports_phpScripts/therapistCaseload.php")
$php := Replace string($template; "//%%PLACEHOLDER%%"; $php)

// 4. Execute PHP to generate PDF
PHP_exec_dynamic_code($php)

// 5. Verify file creation
If (File_DoesExist($outputFilePath))
    // Success - file will be found by Outbox_ProcessItems
End if
```

**PHP Template (`therapistCaseload.php`):**
```php
<?php
require('./../fpdf181/fpdf.php');

class RowData {
    public $name;
    public $dob;
    public $school;
    function __construct($name, $dob, $school) { ... }
}

$tableRowArray = array();
//%%PLACEHOLDER%%  // <-- Injected data goes here

class PDF extends FPDF {
    function Header() {
        $this->SetFont('Arial', 'B', 12);
        $this->Cell(0, 10, 'Therapist Caseload Report', 0, 1, 'C');
    }
    
    function TableRow($name, $dob, $school) {
        $this->Cell(100, 10, $name, 1);
        $this->Cell(50, 10, $dob, 1);
        $this->Cell(100, 10, $school, 1, 1);
    }
}

$pdf = new PDF();
$pdf->AddPage();
foreach ($tableRowArray as $row) {
    $pdf->TableRow($row->name, $row->dob, $row->school);
}
$pdf->Output('F', $outputFilePath);
?>
```

### 2. Excel Reports (PhpSpreadsheet)

**Use Case:** District counts/dollars reports, statistical exports

**Example: District Counts Report**

**Trigger:** `waReports_DistrictCount` → POST to `/reports/district_count`

**Job Creation (Object-Based):**
```4d
var $printJob : Object
$printJob := New object
$printJob.requestedByUserId := WEB_l_UserID
$printJob.reportType := "Stats"
$printJob.methodToCall := "Report_DollarsCounts_ToExcel"
$printJob.description := "Excel version of the 2024 District Counts report."
$printJob.arg1 := "Counts"
$printJob.arg2 := WEB_l_districtID
$printJob.arg3 := $schoolYear
$printJob.arg4 := $valueToShow  // "iep", "ea", or ""
$printJob.argN_outputFileName := "Counts District 001 2024-12-15.xls"

Outbox_CreateJobFromObject($printJob)
```

**`Outbox_CreateJobFromObject` Method:**
```4d
// Converts object to Outbox record
CREATE RECORD([Outbox])
[Outbox]PathToFileOnServer := Outbox_GetFolderPath + $printJob.argN_outputFileName
[Outbox]Status := "Pending"
[Outbox]User_Key := $printJob.requestedByUserId
[Outbox]FileName := $printJob.argN_outputFileName
[Outbox]CodeToExecute := $printJob.methodToCall + " (args...)"
[Outbox]Description := $printJob.description
SAVE RECORD([Outbox])
Outbox_ProcessItems
```

**Report Generation (`Report_DollarsCounts_ToExcel`):**
```4d
// 1. Query aggregated data
QUERY([Treatments]; [Treatments]District_Key = $districtID)
QUERY([Treatments]; [Treatments]School_Year = $schoolYear)
If ($valueToShow = "iep")
    QUERY([Treatments]; [Treatments]isIEP = True)
Else if ($valueToShow = "ea")
    QUERY([Treatments]; [Treatments]isExpandedAccess = True)
End if

// 2. Build PHP data
$php := "$dataArray = array();\r\n"
$php += "$dataArray['totalStudents'] = " + String($totalStudents) + ";\r\n"
$php += "$dataArray['totalTreatments'] = " + String($totalTreatments) + ";\r\n"
$php += "$dataArray['totalRevenue'] = " + String($totalRevenue) + ";\r\n"

// 3. Load and execute PHP template
$template := WebCache_GetTextOfFile("reports_phpScripts/dollarsReport_Excel.php")
$php := Replace string($template; "//%%PLACEHOLDER%%"; $php)
PHP_exec_dynamic_code($php)
```

**PHP Template (`dollarsReport_Excel.php`):**
```php
<?php
require('./../../phpSpreadsheet/common_phpSpreadsheet.php');
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xls;

$dataArray = array();
//%%PLACEHOLDER%%

$spreadsheet = new Spreadsheet();
$sheet = $spreadsheet->getActiveSheet();
$sheet->setCellValue('A1', 'District Counts Report');
$sheet->setCellValue('A3', 'Total Students:');
$sheet->setCellValue('B3', $dataArray['totalStudents']);
$sheet->setCellValue('A4', 'Total Treatments:');
$sheet->setCellValue('B4', $dataArray['totalTreatments']);
$sheet->setCellValue('A5', 'Total Revenue:');
$sheet->setCellValue('B5', $dataArray['totalRevenue']);

$writer = new Xls($spreadsheet);
$writer->save($outputFilePath);
?>
```

### 3. Word Documents (PhpWord)

**Use Case:** Goal planning sheets, treatment plans, IEP documents

**Example: Goals Planning Sheet**

**Report Generation:**
```4d
$template := WebCache_GetTextOfFile("reports_phpScripts/goalsPlanningSheet_asWord.php")
$php := Replace string($template; "//%%PLACEHOLDER%%"; $php_data)
PHP_exec_dynamic_code($php)
```

**PHP Template:**
```php
<?php
require('./../../phpWord/autoload.php');
use PhpOffice\PhpWord\PhpWord;

$phpWord = new PhpWord();
$section = $phpWord->addSection();
$section->addText('Goal Planning Sheet', array('bold' => true, 'size' => 16));
$section->addText('Student: ' . $studentName);
$section->addText('Goal: ' . $goalDescription);

$objWriter = \PhpOffice\PhpWord\IOFactory::createWriter($phpWord, 'Word2007');
$objWriter->save($outputFilePath);
?>
```

### 4. Multi-User Reports

**Pattern:** Loop through selected users, create one Outbox job per user

**Example: Multiple Therapist RFS Reports**

```4d
var $user : cs.UsersEntity
var $num_users_in_report : Integer

For each ($user; $webSelectedTherapists.selected_users)
    $num_users_in_report += 1
    
    $pdf_platformPath := Outbox_GetFolderPath + Outbox_GetUniqueFileNameSegment + " u" + String($user.ID) + " RFS.pdf"
    $code_to_execute := "RptTherapist_RFS (" + String($user.ID) + "; \"" + $pdf_platformPath + "\")"
    $text_to_check_for := $code_to_execute  // For duplicate prevention
    
    If (Outbox_JobDoesNotExist(WEB_l_UserID; $text_to_check_for + "@"))
        WebLog_UpdatePrintCount
        CREATE RECORD([Outbox])
        [Outbox]PathToFileOnServer := $pdf_platformPath
        [Outbox]Status := "Pending"
        [Outbox]User_Key := WEB_l_UserID
        [Outbox]FileName := Date2String(Current date; "MMDDYYYY ") + $user.Last_Name + "_" + Substring($user.First_Name; 1; 1) + " RFS.pdf"
        [Outbox]CodeToExecute := $code_to_execute
        [Outbox]Description := "All the treatments for " + $user.Full_Name + " that are marked as ready for submission."
        SAVE RECORD([Outbox])
        UNLOAD RECORD([Outbox])
    End if
End for each

If ($num_users_in_report = 1)
    WebAlert_AddHtmlMessage("Success"; "The report has been sent to your outbox.")
Else
    WebAlert_AddHtmlMessage("Success"; "The Therapist RFS Report has been sent to your outbox for " + String($num_users_in_report) + " users.")
End if

Outbox_ProcessItems  // Trigger processing
```

### 5. Special Case: Eligibility Reports (Scheduled)

**Unique Characteristics:**
- Runs nightly via daemon (not user-initiated)
- Generates CSV files per district
- Compresses all CSVs into single ZIP file
- Accessible via `/reports/eligibilityReport` endpoint

**Generation (`Report_EligibilityToDisk`):**
```4d
// Called by midnight daemon for each active district
For ($i; 1; Size of array($districtIDs))
    $districtID := $districtIDs{$i}
    $csvPath := Outbox_GetFolderPath + "Eligibility Reports" + Folder separator + String($districtID; "##000") + " Eligibility Report " + $forMonth + ".csv"
    
    // Export student eligibility data to CSV
    EXPORT TEXT([Student]; $csvPath)
End for

// Compress all CSV files into single ZIP
If (Folder_DoesExist(Outbox_GetFolderPath + "Eligibility Reports"))
    Folder_CompressIt(Outbox_GetFolderPath + "Eligibility Reports"; Outbox_GetFolderPath + "EligibilityReports.zip")
End if
```

**Download Handler (`waReports_Main`):**
```4d
: ($url = "reports/eligibilityReport@")
    $filePath := Outbox_GetFolderPath + "EligibilityReports.zip"
    If (File_DoesExist($filePath))
        WebConnect_SendFileAsDownload($filePath; "EligibilityReports.zip")
    Else
        WebConnect_SendPage(WebError_GetErrorPage("Alert"; "The eligibility reports have been queued for regeneration."))
    End if
```

---

## Outbox User Interface

### Viewing the Outbox (`/outbox`)

**Route Handler:** `waOutbox_ShowAll`

**Logic:**
1. Query outbox items for current user: `QUERY([Outbox]; [Outbox]User_Key = WEB_l_UserID)`
2. Filter by date: `QUERY([Outbox]; [Outbox]HideItemAfterDate >= Current date)`
3. Order by creation date: `ORDER BY([Outbox]; [Outbox]Created_Date; <)`
4. Generate HTML table with:
   - Filename (clickable download link if completed)
   - Description
   - Status badge (Pending/Completed/Failed)
   - File size (if completed)
   - Created date/time
   - Delete button

**HTML Template Example:**
```html
<table class="outbox-table">
  <tr>
    <th>File</th>
    <th>Description</th>
    <th>Status</th>
    <th>Size</th>
    <th>Created</th>
    <th>Actions</th>
  </tr>
  <!-- Repeat for each outbox item -->
  <tr>
    <td><a href="/outbox/download?id=123">District Counts 2024.xls</a></td>
    <td>Excel version of the 2024 District Counts report.</td>
    <td><span class="badge badge-success">Completed</span></td>
    <td>45 KB</td>
    <td>2024-12-15 10:30 AM</td>
    <td><a href="/outbox/delete?id=123">Delete</a></td>
  </tr>
</table>
```

### Downloading Files (`/outbox/download`)

**Handler:** `waOutbox_ShowAll` (handles both `/outbox` and `/outbox/download`)

**Logic:**
```4d
: ($url = "/outbox/download@")
    $outboxID := Num(WebSys_GetParam("id"))
    QUERY([Outbox]; [Outbox]ID = $outboxID; *)
    QUERY([Outbox]; & ; [Outbox]User_Key = WEB_l_UserID)  // Security check
    
    If (Records in selection([Outbox]) = 1)
        $filePath := Outbox_ExpandPath([Outbox]PathToFileOnServer)  // Convert {outbox} token to real path
        
        If (File_DoesExist($filePath))
            WebConnect_SendFileAsDownload($filePath; [Outbox]FileName)
        Else
            WebConnect_SendPage(WebError_GetErrorPage("Alert"; "The file no longer exists on the server."))
        End if
    Else
        WebConnect_SendPage(WebError_GetErrorPage("Alert"; "Unauthorized access or file not found."))
    End if
```

### Deleting Items (`/outbox/delete`)

**Handler:** `waOutbox_ShowAll`

**Logic:**
```4d
: ($url = "/outbox/delete@") & ($httpRequestMethod = HTTP POST method)
    $outboxID := Num(WebSys_GetParam("id"))
    QUERY([Outbox]; [Outbox]ID = $outboxID; *)
    QUERY([Outbox]; & ; [Outbox]User_Key = WEB_l_UserID)  // Security check
    
    If (Records in selection([Outbox]) = 1)
        $filePath := Outbox_ExpandPath([Outbox]PathToFileOnServer)
        
        // Delete the physical file
        If (File_DoesExist($filePath))
            File_Delete($filePath)
        End if
        
        // Delete the outbox record
        DELETE RECORD([Outbox])
        
        WebAlert_AddHtmlMessage("Success"; "The item has been deleted.")
    End if
    
    // Redirect back to outbox page
    WebConnect_SendRedirect("/outbox")
```

---

## Helper Methods & Utilities

### Core Outbox Methods (IH_WebShell Component)

#### `Outbox_ProcessItems`
Spawns or wakes the background processing daemon.

```4d
// Check if process already running
If (Process number("Outbox_ProcessItems") <= 0)
    // Spawn new background process
    $processID := New process("Outbox__ProcessLoop"; 0; "Outbox_ProcessItems")
End if
```

#### `Outbox__ProcessLoop` (Background Worker)
Main processing loop running in dedicated process.

```4d
Repeat
    READ WRITE([Outbox])
    QUERY([Outbox]; [Outbox]Status = "Pending"; *)
    QUERY([Outbox]; & ; [Outbox]DelayUntil_DateTimeStamp <= TS_FromDateTime)
    ORDER BY([Outbox]; [Outbox]ID; >)
    
    For ($i; 1; Records in selection([Outbox]))
        $vs := Milliseconds
        
        // Execute the report generation method
        EXECUTE METHOD([Outbox]CodeToExecute)
        
        $ve := Milliseconds
        
        // Update status
        If (File_DoesExist([Outbox]PathToFileOnServer))
            [Outbox]Status := "Completed"
            [Outbox]ResultFileSize := Get document size([Outbox]PathToFileOnServer)
        Else
            [Outbox]Status := "Failed"
        End if
        
        [Outbox]TimeToExecute_in_ms := $ve - $vs
        SAVE RECORD([Outbox])
        
        NEXT RECORD([Outbox])
    End for
    
    // Sleep until more work arrives
    DELAY PROCESS(Current process; 60)  // Check every 60 ticks
Until (Process aborted)
```

#### `Outbox_GetFolderPath` → Text
Returns platform-specific path to WEB_Outbox folder.

```4d
$outboxPath := Get 4D folder(Database folder) + "WEB_Outbox" + Folder separator
return $outboxPath
```

#### `Outbox_GetUniqueFileNameSegment` → Text
Generates unique timestamp-based prefix for filenames.

```4d
$timestamp := String(Milliseconds)
$datestamp := Date2String(Current date; "yyyy-mm-dd")
$uniqueSegment := $datestamp + " " + $timestamp
return $uniqueSegment
```

#### `Outbox_JobDoesNotExist` (userID; codeSnippet) → Boolean
Prevents duplicate job creation by checking pending jobs.

```4d
QUERY([Outbox]; [Outbox]User_Key = $userID; *)
QUERY([Outbox]; & ; [Outbox]Status = "Pending")
QUERY SELECTION([Outbox]; [Outbox]CodeToExecute = $codeSnippet + "@")

If (Records in selection([Outbox]) = 0)
    return True  // Job does not exist (safe to create)
Else
    return False  // Job already exists (skip creation)
End if
```

#### `Outbox_CreateJobFromObject` (jobObject)
Converts object-based job definition to Outbox record.

```4d
CREATE RECORD([Outbox])
[Outbox]PathToFileOnServer := Outbox_GetFolderPath + $jobObject.argN_outputFileName
[Outbox]Status := "Pending"
[Outbox]User_Key := $jobObject.requestedByUserId
[Outbox]FileName := $jobObject.argN_outputFileName
[Outbox]CodeToExecute := $jobObject.methodToCall + " (" + Build_Args_String($jobObject) + ")"
[Outbox]Description := $jobObject.description
SAVE RECORD([Outbox])
Outbox_ProcessItems
```

#### `Outbox_AddTask_doFolderCompress` (userID; srcFolder; dstZipFile; desc; friendlyName)
Specialized method to queue folder compression tasks.

```4d
$codeToExecute := "Folder_CompressIt (\"" + $srcFolder + "\"; \"" + $dstZipFile + "\"; true)"

If (Outbox_JobDoesNotExist($userID; $codeToExecute))
    WebLog_UpdatePrintCount
    CREATE RECORD([Outbox])
    [Outbox]PathToFileOnServer := $dstZipFile
    [Outbox]Status := "Pending"
    [Outbox]User_Key := $userID
    [Outbox]FileName := $friendlyName
    [Outbox]CodeToExecute := $codeToExecute
    [Outbox]Description := $desc
    [Outbox]isClientSafe := False  // Must run on server
    SAVE RECORD([Outbox])
    UNLOAD RECORD([Outbox])
    Outbox_ProcessItems
End if
```

### PHP Integration Methods

#### `PHP_exec_dynamic_code` (phpCode {; arg1; arg2; ...})
Executes dynamically generated PHP code using 4D's PHP plugin.

**Internal Logic:**
1. Writes PHP code to temporary file in `WEB_TEMP/` folder
2. Calls 4D's `PHP Execute` command with temp file path
3. Optionally passes arguments as PHP `$_GET` variables
4. Cleans up temp file after execution

**Usage:**
```4d
$php := "<?php require('./fpdf.php'); $pdf = new FPDF(); ... ?>"
PHP_exec_dynamic_code($php)
```

#### `WebCache_GetTextOfFile` (relativePath) → Text
Loads text file from `Resources/WEB_Private/` folder with caching.

**Logic:**
1. Check in-memory cache for file contents
2. If not cached:
   - Read file from disk: `Resources/WEB_Private/` + $relativePath
   - Store in cache
3. Return cached text

**Usage:**
```4d
$template := WebCache_GetTextOfFile("reports_phpScripts/newEligibles.php")
```

#### `php_safeStr` (text) → Text
Escapes text for safe injection into PHP string literals.

```4d
$safeStr := Replace string($text; "\\"; "\\\\")  // Escape backslashes
$safeStr := Replace string($safeStr; "'"; "\\'")  // Escape single quotes
$safeStr := Replace string($safeStr; "\""; "\\\"")  // Escape double quotes
return $safeStr
```

### Web Alert & Notification

#### `WebAlert_AddHtmlMessage` (type; message)
Adds user-facing notification message to session.

**Types:** `"success"`, `"warning"`, `"error"`, `"info"`

**Usage:**
```4d
WebAlert_AddHtmlMessage("Success"; "The report has been sent to your outbox. <a href=\"/outbox\">View Outbox</a>")
```

**Display:** Messages rendered in HTML template via `<!--#4DHTML WEB_HTML_AlertMessages-->`

---

## Report Methods Catalog

### Core Report Generation Methods

| Method | Output | Description |
|--------|--------|-------------|
| `Report_TherapistCaseLoad` | PDF (fpdf) | Student caseload list for a single therapist |
| `RptTherapist_RFS` | PDF (fpdf) | Ready For Submission (RFS) treatments for therapist |
| `RptTherapist_NewEligibility` | PDF (fpdf) | Newly eligible students for therapist |
| `Report_DollarsCounts_ToExcel` | Excel (PhpSpreadsheet) | District counts/dollars statistical report |
| `Report_UserAccessCounts` | PDF (fpdf) | User access statistics for district |
| `Report_EligibilityToDisk` | CSV + ZIP | All district eligibility reports (scheduled) |
| `Report_EvaluationsByTherapist` | Excel (PhpSpreadsheet) | Evaluations grouped by therapist |
| `Report_PrintCaseloadProgress` | PDF (fpdf) | IEP progress for student(s) in caseload |
| `Print_GoalsPlanningSheet` | PDF/Word | Goal planning sheet for student |
| `Print_TreatmentNotes_PDF` | PDF (fpdf) | Treatment notes for student |
| `Print_CaseloadProgress` | PDF + ZIP | Progress reports for multiple students (generates individual PDFs + combined ZIP) |
| `WebCalendar_PrintRange` | PDF (fpdf) | Treatment calendar for date range |

### Web Action Handlers (Report Initiation)

| Handler | Route | Report Type |
|---------|-------|-------------|
| `waReports_Main` | `/reports` | Main reports menu page |
| `waReports_AllServicesReview` | `/reports/allServicesReview` | All services review CSV |
| `waReports_TherapistCaseLoad` | `/reports/therapistCaseLoad` | Therapist caseload PDF (multi-user) |
| `waReports_NewEligibility` | `/reports/newEligibility` | New eligibility PDF (multi-user) |
| `waReports_TherapistRFS` | `/reports/therapistRFS` | Ready for submission PDF (multi-user) |
| `waReports_IndvThrpProvVsSchd` | `/reports/IndvThrpProvVsSchd` | Individual therapist provided vs scheduled |
| `waReports_ThrpistTrmntPrvdSchd` | `/reports/therapistprvdschd` | Therapist treatments provided vs scheduled |
| `waReports_IEPvsEARevRpt` | `/reports/iepvsearevenuerpt` | IEP vs EA revenue report |
| `waReports_DistrictCount` | `/reports/district_count` | District counts Excel |
| `waReports_DistrictDollars` | `/reports/district_dollars` | District dollars Excel |
| `waReports_UserCounts` | `/reports/userCounts` | User access counts PDF |
| `waReports_HipaaPaidClaims` | `/reports/hipaa_paid_claims` | HIPAA paid claims report |
| `waReports_PeerReview` | `/reports/peerReview` | Peer review report |
| `waReports_TrtmtsBatchAnalysis` | `/reports/treatbybatch` | Treatments batch analysis |
| `waReports_TrtmtsRejectRpt` | `/reports/rejreport` | Treatment reject report |
| `waGoalGraphs_Print` | `/goalGraphs/print` | Goal graph PDF |
| `waTreatmentCalendar_Print` | `/calendar/print` | Treatment calendar PDF |
| `waOutbox_ShowAll` | `/outbox` | Outbox viewer (list, download, delete) |

---

## Security & Authorization

### User-Level Isolation

**Every Outbox job is tied to a specific user:**
```4d
[Outbox]User_Key := WEB_l_UserID  // Current authenticated user
```

**Download Authorization Check:**
```4d
QUERY([Outbox]; [Outbox]ID = $requestedID; *)
QUERY([Outbox]; & ; [Outbox]User_Key = WEB_l_UserID)  // Prevents cross-user access

If (Records in selection([Outbox]) = 0)
    // Unauthorized - user cannot access another user's files
    WebConnect_SendPage(WebError_GetErrorPage("Alert"; "Unauthorized access."))
End if
```

### Report Generation Authorization

**Route-level authorization enforced before job creation:**
- `waReports_DistrictCount` requires `WEB_b_IsDistrictAdmin` or `WEB_b_IsSysAdmin`
- `waReports_TherapistRFS` requires therapist role
- `waReports_HipaaPaidClaims` requires `WEB_b_IsSysAdmin`

**Authorization Object Pattern:**
```4d
// In aa_Shell_Startup_WebAction
$sys_admin_and_up_auth := cs.IH_WebShell.UserAuthorizations.new()
$sys_admin_and_up_auth.requireSysAdmin := True

$router.get_and_post("/reports/hipaa_paid_claims"; "waReports_HipaaPaidClaims"; $sys_admin_and_up_auth)
```

**Handler Authorization Check:**
```4d
: (Not($hasAuthorized))
    WebCore_BadLogin($url)  // Redirect to login or error page
```

### File System Security

**Path Token Usage:**
- All paths stored in database use `{outbox}` token
- Prevents absolute path disclosure
- Centralizes path resolution logic

**File Deletion:**
- Only authenticated user can delete their own outbox items
- Physical file and database record both deleted
- No orphaned files left on disk

---

## Performance & Optimization

### Duplicate Prevention

**Before creating a job, check for existing pending job:**
```4d
$codeToExecute := "Report_TherapistCaseLoad (123; \"/path/to/file.pdf\")"
$textToCheckFor := "Report_TherapistCaseLoad (123;"  // Exclude path (contains timestamp)

If (Outbox_JobDoesNotExist(WEB_l_UserID; $textToCheckFor + "@"))
    // Safe to create job
    CREATE RECORD([Outbox])
    // ...
End if
```

**Benefits:**
- Prevents duplicate report generation
- Reduces server load
- Avoids user confusion (multiple identical files)

### Background Processing

**Advantages:**
- Web request handlers respond instantly (non-blocking)
- Resource-intensive operations run in dedicated process
- Server can prioritize interactive requests

**Process Isolation:**
- `"Outbox_ProcessItems"` process runs independently
- Uses `DELAY PROCESS` for CPU-friendly polling
- Does not interfere with web request handling

### Delayed Execution

**For large reports, defer processing to off-hours:**
```4d
[Outbox]DelayUntil_DateTimeStamp := TS_FromDateTime(Current date; ?22:00:00?)  // 10 PM

// Background process skips jobs where:
QUERY([Outbox]; [Outbox]DelayUntil_DateTimeStamp <= TS_FromDateTime)
```

**Use Cases:**
- Goal graph reports with 50+ pages
- District-wide statistical reports
- Batch operations affecting multiple users

### Client/Server Architecture

**isClientSafe Flag:**
- `True`: Report can run on 4D Remote client (local PHP execution)
- `False`: Report must run on 4D Server (server resources required)

**Example:**
```4d
[Outbox]isClientSafe := True   // PDF generation using local PHP
[Outbox]isClientSafe := False  // Folder compression (server-side file operations)
```

---

## Logging & Monitoring

### Print Count Tracking

**Every report creation increments usage counter:**
```4d
WebLog_UpdatePrintCount
```

**Tracked In:** `[WebLog]` table or statistics system

### Execution Metrics

**Captured Post-Execution:**
- `[Outbox]TimeToExecute_in_ms`: Total generation time
- `[Outbox]ResultFileSize`: File size in bytes
- Status transitions logged (Pending → Completed/Failed)

**Usage:**
```4d
[Outbox]TimeToExecute_in_ms := $end_milliseconds - $start_milliseconds
[Outbox]ResultFileSize := Get document size([Outbox]PathToFileOnServer)
```

### Error Handling

**Failed Jobs:**
```4d
If (Not(File_DoesExist([Outbox]PathToFileOnServer)))
    [Outbox]Status := "Failed"
    Log_ERROR("Report generation failed: " + [Outbox]CodeToExecute)
End if
```

**Status Values:**
- `"Pending"`: Awaiting processing
- `"Processing"`: Currently being generated (optional intermediate state)
- `"Completed"`: Successfully generated
- `"Failed"`: Generation error
- `"Aborted"`: Manually cancelled

---

## Maintenance & Cleanup

### Automatic Cleanup

**Trigger-based expiration:**
```4d
If ([Outbox]HideItemAfterDate = !00-00-00!)
    [Outbox]HideItemAfterDate := Add to date([Outbox]Created_Date; 0; 0; 5)  // 5 days
End if
```

**Query excludes expired items:**
```4d
QUERY([Outbox]; [Outbox]HideItemAfterDate >= Current date)
```

### Manual Deletion

**User-initiated via `/outbox/delete` endpoint:**
1. User clicks "Delete" button in outbox UI
2. Handler validates ownership: `[Outbox]User_Key = WEB_l_UserID`
3. Physical file deleted: `File_Delete($filePath)`
4. Database record deleted: `DELETE RECORD([Outbox])`

### Daemon Cleanup (Optional)

**Periodic purge of old records:**
```4d
// IH_WebShell_Daemon_Maintenance (runs nightly)
QUERY([Outbox]; [Outbox]HideItemAfterDate < Current date - 7)  // 7 days past expiration
DELETE SELECTION([Outbox])
```

---

## Configuration & Environment

### Folder Paths

**Database Root:**
```
<database_root>/
  ├── WEB_Outbox/                   ← Reports stored here
  │   ├── Eligibility Reports/       ← District CSVs
  │   └── EligibilityReports.zip     ← Compressed eligibility bundle
  ├── Resources/
  │   └── WEB_Private/
  │       └── reports_phpScripts/    ← PHP templates
  ├── Resources_PHP/                 ← PHP libraries
  │   ├── fpdf181/                   ← PDF generation
  │   ├── phpSpreadsheet/            ← Excel generation
  │   └── phpWord/                   ← Word generation
  └── WEB_TEMP/                      ← Temporary PHP script files
```

### PHP Configuration

**PHP Executable:**
- Configured in 4D preferences or via plugin settings
- Windows: `Resources_PHP/php_ForWindows/php.exe`
- macOS: System PHP or bundled PHP

**Required PHP Extensions:**
- GD (image manipulation for PDF graphics)
- ZIP (compression for Excel files)
- XML (PhpSpreadsheet dependencies)

### Component Dependencies

**IH_WebShell Component:**
- `Outbox_ProcessItems`
- `Outbox_GetFolderPath`
- `Outbox_GetUniqueFileNameSegment`
- `Outbox_JobDoesNotExist`
- `Outbox_CreateJobFromObject`
- `Outbox_AddTask_doFolderCompress`

**IH_Core Component:**
- `WebCache_GetTextOfFile`
- `PHP_exec_dynamic_code`
- `php_safeStr`
- `File_DoesExist`
- `File_Delete`
- `File_GetFileName`
- `Folder_CompressIt`
- `Date2String`
- `Milliseconds`

---

## Best Practices

### 1. Report Method Design

**Signature Convention:**
```4d
// Method: Report_TherapistCaseLoad
// Signature: Report_TherapistCaseLoad (userID; outputFilePath)
// Returns: Boolean (success)
```

**Always Include:**
- Parameter validation: `ASSERT(Count parameters = 2)`
- Profiling: `Profiler_START(Current method name)`
- Error handling: `OnErr_Install_Handler`
- File existence check before marking completed

### 2. Job Creation Pattern

**Standard Flow:**
```4d
// 1. Build unique filename
$filename := Outbox_GetFolderPath + Outbox_GetUniqueFileNameSegment + " " + $descriptiveName + ".pdf"

// 2. Build code to execute (without path for duplicate check)
$codeToExecute := "Report_MyReport (" + String($arg1) + "; "
$textToCheckFor := $codeToExecute  // For duplicate prevention
$codeToExecute += "\"" + $filename + "\")"

// 3. Check for duplicates
If (Outbox_JobDoesNotExist(WEB_l_UserID; $textToCheckFor + "@"))
    // 4. Increment usage counter
    WebLog_UpdatePrintCount
    
    // 5. Create outbox record
    CREATE RECORD([Outbox])
    [Outbox]PathToFileOnServer := $filename
    [Outbox]Status := "Pending"
    [Outbox]User_Key := WEB_l_UserID
    [Outbox]FileName := "My Report.pdf"
    [Outbox]CodeToExecute := $codeToExecute
    [Outbox]Description := "Detailed description for user."
    [Outbox]isClientSafe := True
    SAVE RECORD([Outbox])
    UNLOAD RECORD([Outbox])
    
    // 6. Trigger processing
    Outbox_ProcessItems
End if

// 7. Notify user
WebAlert_AddHtmlMessage("Success"; "The report has been sent to your outbox. <a href=\"/outbox\">View Outbox</a>")
```

### 3. PHP Template Structure

**Template File (`reports_phpScripts/myReport.php`):**
```php
<?php
require('./../fpdf181/fpdf.php');  // Adjust path based on location
set_time_limit(300);  // Allow 5 minutes for generation

// Data structure definitions
class RowData {
    public $field1;
    public $field2;
    // ...
}

// Data placeholder (injected by 4D)
$dataArray = array();
//%%PLACEHOLDER%%

// PDF generation logic
class PDF extends FPDF {
    function Header() { /* ... */ }
    function Footer() { /* ... */ }
}

$pdf = new PDF();
$pdf->AddPage();

// Iterate over data
foreach ($dataArray as $row) {
    $pdf->Cell(100, 10, $row->field1, 1);
    $pdf->Cell(100, 10, $row->field2, 1, 1);
}

// Output to file (not inline)
$pdf->Output('F', $outputFilePath);
?>
```

**4D Data Injection:**
```4d
$php := "$dataArray = array();\r\n"

For ($i; 1; Records in selection([MyTable]))
    $php += "$dataArray[] = new RowData();\r\n"
    $php += "$dataArray[" + String($i-1) + "]->field1 = '" + php_safeStr([MyTable]Field1) + "';\r\n"
    $php += "$dataArray[" + String($i-1) + "]->field2 = '" + php_safeStr([MyTable]Field2) + "';\r\n"
    NEXT RECORD([MyTable])
End for

$template := WebCache_GetTextOfFile("reports_phpScripts/myReport.php")
$php := Replace string($template; "//%%PLACEHOLDER%%"; $php)
PHP_exec_dynamic_code($php)
```

### 4. Multi-User Reports

**Pattern: Loop + Individual Jobs**
```4d
var $users : Collection
var $user : Object

$users := Get_Selected_Users()  // Custom logic

For each ($user; $users)
    // Create one job per user
    $filename := Outbox_GetFolderPath + "u" + String($user.id) + " " + String(Milliseconds) + " Report.pdf"
    $codeToExecute := "Report_MyReport (" + String($user.id) + "; \"" + $filename + "\")"
    
    If (Outbox_JobDoesNotExist(WEB_l_UserID; $codeToExecute))
        CREATE RECORD([Outbox])
        // ... (standard job creation)
        SAVE RECORD([Outbox])
    End if
End for each

Outbox_ProcessItems
WebAlert_AddHtmlMessage("Success"; "Reports queued for " + String($users.length) + " users.")
```

### 5. Error Recovery

**In Report Method:**
```4d
OnErr_Install_Handler("OnErr_MAIN_ErrorHandler")

// Attempt generation
$success := GeneratePDF($outputPath)

If (Not($success)) | (Not(File_DoesExist($outputPath)))
    // Log error
    Log_ERROR("Report generation failed: " + Current method name + " Args: " + JSON Stringify($args))
    
    // Optionally notify user via email
    EMail_Send_ErrorNotification(WEB_l_UserID; "Report failed: " + [Outbox]Description)
End if

return $success
```

---

## Common Troubleshooting

### Issue: Reports Stuck in "Pending" Status

**Causes:**
1. Background process not running
2. PHP execution error
3. File permission issues

**Solutions:**
```4d
// Check if background process is running
$processNum := Process number("Outbox_ProcessItems")
If ($processNum <= 0)
    Outbox_ProcessItems  // Restart background process
End if

// Manually trigger processing
CALL WORKER("NotThreadSafe"; "Outbox_ProcessItems")
```

### Issue: PHP Errors

**Check PHP Error Log:**
- Windows: `Resources_PHP/php_ForWindows/php_errors.log`
- macOS: `/var/log/apache2/error_log` or system log

**Common Errors:**
- "Failed to load fpdf.php": Incorrect path in `require()` statement
- "Memory limit exceeded": Increase PHP `memory_limit` in `php.ini`
- "Maximum execution time exceeded": Increase `set_time_limit(300)` in PHP script

### Issue: Files Not Appearing in Outbox

**Check:**
1. User ID mismatch: `[Outbox]User_Key` vs `WEB_l_UserID`
2. Expiration date: `[Outbox]HideItemAfterDate` already passed
3. Status filter: Query includes `[Outbox]Status = "Completed"`

**Debug Query:**
```4d
QUERY([Outbox]; [Outbox]User_Key = WEB_l_UserID)
QUERY([Outbox]; [Outbox]Status # "Failed")
ORDER BY([Outbox]; [Outbox]Created_Date; <)
```

### Issue: Duplicate Jobs Created

**Root Cause:** `Outbox_JobDoesNotExist` not called or incorrect code signature

**Fix:**
```4d
// Ensure duplicate check uses consistent signature
$codeToExecute := "Report_MyReport (" + String($arg1) + "; "
$textToCheckFor := $codeToExecute  // WITHOUT file path
$codeToExecute += "\"" + $filename + "\")"  // Add path after check

If (Outbox_JobDoesNotExist(WEB_l_UserID; $textToCheckFor + "@"))
    // Safe to create job
End if
```

---

## Integration with Queued Tasks

**Related System:** `[Queued_Tasks]` table handles long-running background jobs not tied to specific users

**Key Differences:**

| Feature | Outbox | Queued Tasks |
|---------|--------|--------------|
| **User Association** | Yes (`User_Key`) | Optional (`Record_Key`) |
| **UI Visibility** | Yes (per-user outbox page) | No (admin monitoring only) |
| **File Output** | Always generates downloadable files | May or may not create files |
| **Duplicate Prevention** | User-centric (per-user queue) | System-centric (task digest) |
| **Example Use Cases** | PDF reports, Excel exports | Eligibility imports, batch calculations, HIPAA adjustments |

**Interaction:**
- Some tasks create Outbox records as final step
- Example: Eligibility import (Queued Task) → Generate CSVs → Compress to ZIP (Outbox compression task)

```4d
// In Queued Task handler:
Report_EligibilityToDisk($districtID)  // Generates CSVs

// Then create Outbox job to compress folder:
Outbox_AddTask_doFolderCompress(
    $userID;
    Outbox_GetFolderPath + "Eligibility Reports";
    Outbox_GetFolderPath + "EligibilityReports.zip";
    "Compressed eligibility reports for all districts";
    "EligibilityReports.zip"
)
```

---

## Future Enhancements

### Potential Improvements

1. **Real-Time Status Updates**
   - WebSocket or polling to update outbox page without refresh
   - Show progress percentage for long-running reports

2. **Email Notifications**
   - Send email when report completes
   - Include direct download link (secure token-based)

3. **Report Scheduling**
   - Allow users to schedule recurring reports (weekly, monthly)
   - Store schedule in new `[Report_Schedule]` table

4. **Batch Download**
   - Checkbox selection in outbox UI
   - Download multiple reports as single ZIP

5. **Report Templates**
   - User-customizable report templates
   - Save filter/parameter presets

6. **Cloud Storage Integration**
   - Upload completed reports to Google Drive, Dropbox, etc.
   - Reduce local disk usage

7. **Report Sharing**
   - Share report with other users (grant temporary access)
   - Generate shareable link with expiration

8. **Priority Queue**
   - Add `[Outbox]Priority` field
   - Process high-priority reports first

---

## Appendix: PHP Libraries

### fpdf (PDF Generation)

**Version:** 1.81  
**Location:** `Resources_PHP/fpdf181/`  
**Documentation:** http://www.fpdf.org/

**Key Classes:**
- `FPDF`: Base PDF class
- Methods: `AddPage()`, `SetFont()`, `Cell()`, `MultiCell()`, `Image()`, `Output()`

**Custom Extensions:**
- `CellFitScale()`: Auto-scales text to fit cell width
- Custom header/footer methods

### PhpSpreadsheet (Excel Generation)

**Location:** `Resources_PHP/phpSpreadsheet/`  
**Autoload:** `common_phpSpreadsheet.php`  
**Documentation:** https://phpspreadsheet.readthedocs.io/

**Key Classes:**
- `PhpOffice\PhpSpreadsheet\Spreadsheet`
- `PhpOffice\PhpSpreadsheet\Writer\Xls`
- `PhpOffice\PhpSpreadsheet\Writer\Xlsx`

**Common Operations:**
- `$sheet->setCellValue('A1', $value)`
- `$sheet->getStyle('A1')->getFont()->setBold(true)`
- `$writer = new Xls($spreadsheet); $writer->save($path)`

### PhpWord (Word Generation)

**Location:** `Resources_PHP/phpWord/`  
**Autoload:** `autoload.php`  
**Documentation:** https://phpword.readthedocs.io/

**Key Classes:**
- `PhpOffice\PhpWord\PhpWord`
- `PhpOffice\PhpWord\IOFactory`

**Common Operations:**
- `$section = $phpWord->addSection()`
- `$section->addText($text, $fontStyle)`
- `$writer = IOFactory::createWriter($phpWord, 'Word2007'); $writer->save($path)`

---

## Summary

The ezEdMed Outbox & Reporting System provides a robust, user-friendly architecture for asynchronous report generation. By decoupling resource-intensive operations from web request handlers, the system maintains responsive performance while delivering complex multi-format reports (PDF, Excel, Word) to users via a centralized outbox interface.

**Key Strengths:**
- **Scalability:** Background processing prevents web server blocking
- **User Experience:** Instant acknowledgment, transparent status tracking
- **Flexibility:** Supports single-user and multi-user report batches
- **Reliability:** Duplicate prevention, error handling, automatic cleanup
- **Extensibility:** Easy to add new report types using existing patterns

**Architecture Principles:**
- **Separation of Concerns:** Request handling ↔ Report generation ↔ File delivery
- **Database-Driven Queue:** Persistent job registry survives server restarts
- **Component Modularity:** Core logic in reusable IH_WebShell component
- **Template-Based Generation:** PHP templates enable rich formatting without 4D Write dependencies
