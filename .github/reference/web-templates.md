# Web Template Architecture

## Overview

The EEM-KY web application uses a **template-based architecture** where HTML files in `Resources/WEB_Private/` serve as dynamic templates processed by the 4D web server. These templates use special 4D tags to inject dynamic content, execute server-side logic, and reference static assets from `Resources/WEB_Public/`.

**Key Principles:**
- **Separation of Concerns:** Templates (WEB_Private) vs. Static Assets (WEB_Public)
- **Component-based Layout:** Reusable includes for headers, footers, navigation
- **Server-side Processing:** 4D tags execute methods and inject dynamic content
- **Security:** CSRF tokens, CSP nonces, and authorization checks
- **Template Composition:** Parent-child template inheritance via includes

---

## Directory Structure

### WEB_Private/ - Dynamic Templates

```
Resources/WEB_Private/
├── admin/                      # Administration pages
│   ├── eligibility.html
│   ├── stateConfig.html
│   └── main_admin_page.html
├── batch/                      # Batch upload/processing
│   ├── upload.html
│   ├── verify.html
│   ├── detail.html
│   └── main.html
├── district/                   # District management
│   ├── detail.html
│   └── showall.html
├── errors/                     # Error pages
│   ├── error_alert.html
│   ├── error_baduser.html
│   ├── error_badurl.html
│   └── error_response.html
├── graphingGoal/              # Goal graphing pages
│   ├── graphingGoals_stage_1.html
│   └── blank_page.html
├── includes/                   # Reusable template fragments
│   ├── page_start.html        # Standard page header
│   ├── page_end.html          # Standard page footer
│   ├── inc_page_header.html   # Alternative header
│   ├── inc_page_footer.html   # Alternative footer
│   ├── inc_navigation.html    # Left navigation
│   ├── header.html            # Top banner
│   ├── tab_bar.html           # Tab navigation
│   ├── inc_footer.html        # Bottom footer
│   └── _Custom_Stylesheet_elements.html
├── main/                       # Main application pages
│   ├── Main_Page.html         # Student dashboard
│   ├── user_template.html     # User page template
│   ├── student/               # Student detail pages
│   │   ├── studentDashboard.html
│   │   ├── tab/              # Student detail tabs
│   │   │   ├── treatment_plan_detail.html
│   │   │   ├── treatments.html
│   │   │   ├── ieps_goals.html
│   │   │   └── goal_detail.html
│   │   └── tab_details/      # Tab content fragments
│   │       ├── ieps.html
│   │       ├── treatment_plans_list.html
│   │       └── goals_objectives_list.html
│   └── progress/              # Progress reporting
│       └── progress_date_range.html
├── messaging/                  # Messaging pages
│   └── main.html
├── reporting/                  # Custom report designer
│   ├── main.html
│   └── main_stage2.html
├── reports/                    # Standard reports
│   ├── hippaPaidClaims.html
│   ├── peer_review_report.html
│   ├── Counts.html
│   ├── Dollars.html
│   └── main_reports_page.html
├── reports_phpScripts/        # PHP report generators
│   ├── goalsPlanningSheet_asPDF.php
│   ├── mentalHealthTreatmentPlans_toPDF.php
│   └── newEligibles.php
├── treatments/                 # Treatment calendar pages
│   └── calendar/
│       ├── daily.html
│       ├── weekly.html
│       └── monthly.html
└── TEMPLATES/                  # Email & calendar templates
    ├── SummaryEmail_HTML_Start.txt
    ├── SummaryEmail_HTML_End.txt
    ├── MonthlyCalendar.txt
    └── ForgottenPassword.txt
```

### WEB_Public/ - Static Assets

```
Resources/WEB_Public/
├── EEM/                        # Application-specific assets
│   ├── ezedmed_style-2025-10-15.css  # Main stylesheet
│   ├── ezedmed_script-2026-03-17.js  # Main JavaScript
│   ├── wcag.css               # Accessibility styles
│   ├── search.css             # Search interface styles
│   ├── login.css              # Login page styles
│   └── tags.css               # Tag component styles
├── jquery/                     # jQuery library & plugins
│   ├── js/
│   │   ├── jquery-3.7.1.min.js
│   │   ├── jquery-ui.min.js
│   │   ├── jquery-idleTimeout.js
│   │   └── jquery.combobox.js
│   └── css/redmond/jquery-ui.css
├── js/                         # Vanilla JavaScript
│   ├── drop_down.js           # Dropdown menu logic
│   └── rounded.js             # UI enhancements
├── css/                        # Additional stylesheets
│   ├── drop_down.css
│   └── google-fonts.css
├── fontawesome-free-6.5.2-web/ # Font Awesome icons
│   └── css/all.min.css
├── chart.js/                   # Chart.js charting library
│   ├── chart-4.3.1.umd.min.js
│   ├── chartjs-plugin-annotation-3.0.1.min.js
│   └── chartjs-plugin-datalabels-2.2.0.min.js
├── fusioncharts/              # FusionCharts library
│   ├── fusioncharts.js
│   ├── fusioncharts.charts.js
│   └── maps/
├── dropzone/                   # File upload widget
│   ├── dropzone.min.js
│   └── dropzone.min.css
├── file_uploader/             # Alternative file uploader
│   └── fileuploader.css
├── calendar/                   # Calendar styles
│   └── calendar.css
├── favicon.ico                 # Browser icon
├── favicon-16x16.png          # Various sizes
├── favicon-32x32.png
├── apple-touch-icon.png       # iOS icons
└── mstile-144x144.png         # Windows tiles
```

---

## 4D Template Tags

### Tag Syntax

4D templates use HTML comment-based tags for server-side processing:

| Tag Type | Syntax | Purpose |
|----------|--------|---------|
| **Method Execution (HTML)** | `<!--#4DHTML MethodName-->` | Execute method, insert returned HTML |
| **Method Execution (Script)** | `<!--#4DSCRIPT/MethodName-->` | Execute method, no output (side effects only) |
| **Variable Output** | `<!--#4DTEXT variableName-->` | Insert text variable value |
| **Variable Output (Raw)** | `<!--#4DVAR variableName-->` | Insert variable value (for attributes) |
| **Conditional** | `<!--#4Dif (condition)-->...<!--#4Dendif-->` | Conditional rendering |
| **Else** | `<!--#4Delse-->` | Else clause for conditionals |

### Examples

**Method Execution with HTML Output:**
```html
<!--#4DHTML WebUtil_PageStart("Student Dashboard")-->
```
Calls `WebUtil_PageStart("Student Dashboard")` and inserts the returned HTML.

**Variable Interpolation:**
```html
<title><!--#4DTEXT WEB_t_pageTitle--></title>
```
Inserts the value of `WEB_t_pageTitle` variable into the title tag.

**CSP Nonce Attributes:**
```html
<script nonce="<!--#4DVAR WebSys_GetCSPScriptNonce()-->">
```
Calls method and inserts result as attribute value (no HTML escaping).

**Conditional Rendering:**
```html
<!--#4Dif (WEB_b_isInfoHandlerEmployee)-->
    <div class="admin-tools">Administrator Tools</div>
<!--#4Delse-->
    <div class="user-tools">User Tools</div>
<!--#4Dendif-->
```

**Script Execution (No Output):**
```html
<!--#4DSCRIPT/WebScript_Verify_Eligibility-->
```
Executes method for side effects (set variables, logging, etc.).

---

## Template Composition Pattern

### Layout Inheritance

Templates use includes to compose pages from reusable fragments:

#### Pattern 1: Standard Page Layout

```html
<!--#4DHTML WebUtil_PageStart("Page Title")-->

<!-- Page-specific content goes here -->
<h3>My Page Content</h3>
<p>Content details...</p>

<!--#4DHTML WebUtil_PageEnd-->
```

**What happens:**
1. `WebUtil_PageStart()` includes `page_start.html`:
   - DOCTYPE, `<html>`, `<head>` tags
   - Meta tags, CSS links, JavaScript includes
   - Page header, navigation, tab bar
   - Alert message display div
2. Page-specific content is inserted
3. `WebUtil_PageEnd()` includes `page_end.html`:
   - Closes content divs
   - Footer
   - Closing `</body>` and `</html>` tags
   - Focus management scripts

#### Pattern 2: Manual Component Assembly

```html
<!--#4DHTML WebUtil_Include("/includes/inc_page_header.html")-->
<!--#4DHTML WebUtil_Include("/includes/inc_User_Navigation.html")-->

<!-- Page content -->

<!--#4DHTML WebUtil_Include("/includes/inc_page_footer.html")-->
```

**Manual approach** gives more control over layout structure.

#### Pattern 3: Simple Administrative Page

```html
<!--#4DHTML WebUtil_PageStart("Administration")-->

<!--#4DHTML WebScript_Verify_Eligibility -->

<!--#4DHTML WebUtil_PageEnd-->
```

**Minimal template** - business logic handled entirely by the method call.

---

## Standard Page Structure

### Complete Page Anatomy

```html
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title><!--#4DTEXT WEB_t_pageTitle--></title>
    
    <!-- CSS: jQuery UI -->
    <link rel="stylesheet" href="/jquery/css/redmond/jquery-ui.css">
    
    <!-- CSS: Application Styles -->
    <link rel="stylesheet" href="/EEM/ezedmed_style-2025-10-15.css">
    <link rel="stylesheet" href="/EEM/wcag.css">
    <link rel="stylesheet" href="/EEM/search.css">
    
    <!-- CSS: Third-party -->
    <link rel="stylesheet" href="/fontawesome-free-6.5.2-web/css/all.min.css">
    <link rel="stylesheet" href="/dropzone/dropzone.min.css"/>
    
    <!-- CSS: Custom District Overrides -->
    <!--#4DHTML WebUtil_Include("/includes/_Custom_Stylesheet_elements.html")-->
    
    <!-- JavaScript: jQuery -->
    <script nonce="<!--#4DVAR WebSys_GetCSPScriptNonce()-->" 
            src="/jquery/js/jquery-3.7.1.min.js"></script>
    <script nonce="<!--#4DVAR WebSys_GetCSPScriptNonce()-->" 
            src="/jquery/js/jquery-ui.min.js"></script>
    
    <!-- JavaScript: Application -->
    <script nonce="<!--#4DVAR WebSys_GetCSPScriptNonce()-->" 
            src="/EEM/ezedmed_script-2026-03-17.js"></script>
    
    <!-- Favicons -->
    <link rel="icon" type="image/png" href="/favicon-32x32.png" sizes="32x32">
    <link rel="apple-touch-icon" href="/apple-touch-icon.png">
</head>

<body>
    <!--#4DHTML WebUtil_Include("/includes/header.html")-->
    <!--#4DHTML WebUtil_Include("/includes/tab_bar.html")-->
    
    <table id="main" width="100%" border="0">
        <tr valign="top">
            <td id="leftcol">
                <!--#4DHTML WebUtil_Include("/includes/inc_navigation.html")-->
            </td>
            <td>
                <div id="bodycol" class="app">
                    <!-- Alert Messages -->
                    <!--#4Dif (WebAlert_GetMessage#"")-->
                        <!--#4Dif (WebAlert_GetMessage("Success")#"")-->
                            <div class="alert alert-success" role="alert">
                                <!--#4DHTML WebAlert_GetMessage("Success")-->
                            </div>
                        <!--#4Dendif-->
                        
                        <!--#4Dif (WebAlert_GetMessage("Error")#"")-->
                            <div class="alert alert-danger" role="alert">
                                <!--#4DHTML WebAlert_GetMessage("Error")-->
                            </div>
                        <!--#4Dendif-->
                    <!--#4Dendif-->
                    
                    <!-- PAGE CONTENT GOES HERE -->
                    
                </div>
            </td>
        </tr>
    </table>
    
    <!--#4DHTML WebUtil_Include("/includes/inc_footer.html")-->
    
    <!-- Focus Management -->
    <!--#4Dif (WebSys_GetParam("focus_on_element_with_id")#"")-->
        <script nonce="<!--#4DVAR WebSys_GetCSPScriptNonce()-->">
            $(document).ready(function() {
                doFocusById("<!--#4DTEXT WebSys_GetParam("focus_on_element_with_id")-->");
            });
        </script>
    <!--#4Dendif-->
</body>
</html>
```

---

## Common Template Patterns

### 1. Form with Dynamic Content

```html
<!--#4DHTML WebUtil_PageStart("Student Details")-->

<h3>Student Details: <!--#4DHTML woStudent_Header([Student]Student_ID)--></h3>

<form action="/students/treatment_plans" method="post">
    <input type="hidden" name="CSRF_Token" 
           value="<!--#4DTEXT Sessions_Get_CSRFToken(WEB_t_sessionID)-->">
    
    <!--#4DHTML woTreatmentPlans_Detail([Treatment_Plans]ID)-->
</form>

<!--#4DHTML WebUtil_PageEnd-->
```

**Pattern Breakdown:**
- `WebUtil_PageStart()` - Full page chrome
- `woStudent_Header()` - Returns HTML for student name/info
- CSRF token for security (inserted via `#4DTEXT`)
- `woTreatmentPlans_Detail()` - Generates form fields dynamically
- `WebUtil_PageEnd()` - Close page chrome

### 2. Tabbed Interface

```html
<!--#4DHTML WebUtil_PageStart("Daily Calendar")-->

<!--#4DHTML woHTML_Tab_BEGIN-->
<!--#4DHTML woHTML_Tab_SetTabItem("daily"; "daily"; "Daily Calendar"; "/treatments/calendar/daily?reset=y")-->
<!--#4DHTML woHTML_Tab_SetTabItem("weekly"; "daily"; "Weekly Calendar"; "/treatments/calendar/weekly?reset=y")-->
<!--#4DHTML woHTML_Tab_SetTabItem("monthly"; "daily"; "Monthly Calendar"; "/treatments/calendar/monthly?reset=y")-->
<!--#4DHTML woHTML_Tab_END-->

<!-- Tab content -->
<form action="/treatments/calendar/daily/doEvent" method="POST">
    <input type="hidden" name="CSRF_Token" 
           value="<!--#4DTEXT Sessions_Get_CSRFToken(WEB_t_sessionID)-->">
    <!--#4DHTML woCalendar_doDailyCalendar-->
</form>

<!--#4DHTML WebUtil_PageEnd-->
```

**Tab Pattern:**
- `woHTML_Tab_BEGIN()` starts tab rendering
- Multiple `woHTML_Tab_SetTabItem()` calls define tabs
- `woHTML_Tab_END()` renders complete tab bar
- Content follows with tab-specific data

### 3. Search/List Page

```html
<!--#4DHTML WebUtil_PageStart("Student Dashboard")-->

<form action="/main" method="Post" autocomplete="off">
    <input type="hidden" name="CSRF_Token" 
           value="<!--#4DTEXT Sessions_Get_CSRFToken(WEB_t_sessionID)-->">
    
    Student Search:
    <div class="search_bar small">
        <input autofocus type="text" name="searchTerm" 
               value="<!--4Dtext Websys_GetParam("searchTerm")-->" 
               placeholder="First, Last, ID, MID, DOB or School" />
        <button type="submit" name="searchTerm_doSearch">Search</button>
    </div>
    
    <!--#4Dif (User_HasAuthorization("isDistrictAdmin"))-->
        <!-- Admin-only filters -->
        <div class="inline">
            <input type="checkbox" name="doLimitToEligibleOnly" 
                   <!--#4Dtext Websys_GetParam("doLimitToEligibleOnly")-->>
            Only Show
            <select name="doLimitToEligible">
                <!--#4DHTML WebScript_LoadListArrays("/StudentEligibileListAsHTML")-->
            </select>
        </div>
    <!--#4Dendif-->
</form>

<!--#4DHTML WebSRCHLIST_RenderListAsHTML(WEB_t_sessionID; "Student")-->

<!--#4DHTML WebUtil_PageEnd-->
```

**Search Pattern:**
- Form preserves search state via `Websys_GetParam()`
- Authorization checks control UI visibility
- Dynamic dropdown population
- Search results rendered by list method

### 4. Error Page

```html
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Error</title>
    <link rel="stylesheet" href="/EEM/ezedmed_style-2025-10-15.css">
    <script nonce="<!--#4DVAR WebSys_GetCSPScriptNonce()-->" 
            src="/EEM/ezedmed_script-2026-03-17.js"></script>
</head>
<body>
    <div class="error-container">
        <h2>An Error Occurred</h2>
        <p><!--#4DHTML ERR_t_errorText--></p>
        
        <script nonce="<!--#4DVAR WebSys_GetCSPScriptNonce()-->">
            setTimeout(function() {
                window.location.href = '/main';
            }, 5000);
        </script>
    </div>
</body>
</html>
```

**Error Pattern:**
- Minimal page structure (no standard includes)
- Direct error message insertion
- Auto-redirect after timeout

---

## Security Features

### 1. CSRF Protection

All forms include CSRF tokens:

```html
<form action="/students/save" method="post">
    <input type="hidden" name="CSRF_Token" 
           value="<!--#4DTEXT Sessions_Get_CSRFToken(WEB_t_sessionID)-->">
    <!-- form fields -->
</form>
```

**Server-side validation:**
```4d
If (Sessions_Validate_CSRFToken(WEB_t_sessionID; WebSys_GetParam("CSRF_Token")))
    // Process form
Else
    // Reject request
End if
```

### 2. Content Security Policy (CSP)

**Inline Scripts with Nonces:**
```html
<script nonce="<!--#4DVAR WebSys_GetCSPScriptNonce()-->">
    // Inline JavaScript code
    $(document).ready(function() {
        // jQuery code
    });
</script>
```

**Inline Styles with Nonces:**
```html
<style nonce="<!--#4DHTML WebSys_GetCSPStyleNonce()-->">
    .custom-class {
        background-color: #efefef;
    }
</style>
```

**Why nonces?**
- Prevents XSS attacks from injected inline scripts
- Each page load generates unique nonce
- CSP header only allows scripts/styles with matching nonce

### 3. Authorization Checks

**Conditional UI based on permissions:**
```html
<!--#4Dif (User_HasAuthorization("isSystemAdmin"))-->
    <div class="admin-panel">
        <button type="submit" name="deleteAll">Delete All Records</button>
    </div>
<!--#4Dendif-->

<!--#4Dif (WEB_b_isInfoHandlerEmployee | User_HasAuthorization("isSystemAdmin"))-->
    <a href="/admin/stateConfig">State Configuration</a>
<!--#4Dendif-->
```

**Common authorization variables:**
- `WEB_b_isSysAdmin` - System administrator
- `WEB_b_isRestrictedSysAdmin` - Restricted admin
- `WEB_b_isInfoHandlerEmployee` - InfoHandler staff
- `WEB_b_isActingAsAnother` - Acting as another user
- `User_HasAuthorization("role")` - Function-based check

### 4. Input Sanitization

**Safe variable output:**
```html
<!-- Automatically HTML-escaped -->
<p>Student Name: <!--#4DTEXT [Student]First_Name--></p>

<!-- For attributes, use Websys_GetParam which sanitizes -->
<input type="text" name="email" 
       value="<!--#4DTEXT WebSys_GetParam("email")-->">
```

**Unsafe patterns to avoid:**
```html
<!-- DON'T: Direct variable concatenation in HTML generation methods -->
$html := "<p>Name: "+[Student]First_Name+"</p>"  // No escaping!

<!-- DO: Use HTML_Escape -->
$html := "<p>Name: "+HTML_Escape([Student]First_Name)+"</p>"
```

---

## Asset Loading Strategy

### CSS Loading Order

```html
<head>
    <!-- 1. Third-party CSS first -->
    <link rel="stylesheet" href="/jquery/css/redmond/jquery-ui.css">
    <link rel="stylesheet" href="/fontawesome-free-6.5.2-web/css/all.min.css">
    
    <!-- 2. Application base styles -->
    <link rel="stylesheet" href="/EEM/ezedmed_style-2025-10-15.css">
    
    <!-- 3. Feature-specific styles -->
    <link rel="stylesheet" href="/EEM/wcag.css">
    <link rel="stylesheet" href="/EEM/search.css">
    <link rel="stylesheet" href="/dropzone/dropzone.min.css">
    
    <!-- 4. District-specific overrides (loaded last) -->
    <!--#4DHTML WebUtil_Include("/includes/_Custom_Stylesheet_elements.html")-->
</head>
```

**Rationale:**
- Third-party CSS establishes baseline
- Application styles override third-party
- Custom district styles override everything

### JavaScript Loading Order

```html
<!-- jQuery must load first -->
<script nonce="..." src="/jquery/js/jquery-3.7.1.min.js"></script>
<script nonce="..." src="/jquery/js/jquery-ui.min.js"></script>

<!-- jQuery plugins require jQuery -->
<script nonce="..." src="/jquery/js/jquery-idleTimeout.js"></script>
<script nonce="..." src="/jquery/js/jquery.combobox.js"></script>

<!-- Application JavaScript -->
<script nonce="..." src="/EEM/ezedmed_script-2026-03-17.js"></script>

<!-- Page-specific scripts -->
<script nonce="..." src="/js/drop_down.js"></script>
```

**Loaded at end of body:**
```html
<body>
    <!-- Page content -->
    
    <!-- Scripts loaded here don't block page rendering -->
    <script nonce="..." src="/js/drop_down.js"></script>
</body>
```

### Cache-Busting Strategy

**Version in filename:**
```html
<link rel="stylesheet" href="/EEM/ezedmed_style-2025-10-15.css">
<script src="/EEM/ezedmed_script-2026-03-17.js"></script>
```

**Updating assets:**
1. Modify CSS/JS file
2. Rename with new date: `ezedmed_style-2025-01-26.css`
3. Update all template references
4. Browser sees new filename, downloads fresh copy

---

## Dynamic Content Generation

### Server-side Form Generation (WebFORM)

**4D Method generates HTML:**
```4d
// woTreatmentPlans_Detail
#DECLARE($plan_id : Integer) -> $html : Text

var $web_form : Object
$web_form := WebFORM_Init("/students/treatment_plans"; 2)
WebFORM_SetFormNameAndResubmit($web_form; "treatment_plan"; True)
WebFORM_SetForm_ModByUserID($web_form; WEB_l_UserID)

// Add form fields
WebFORM_AddFieldValue($web_form; 2; "Plan Name"; ->[Treatment_Plans]Name; "")
WebFORM_AddFieldValue($web_form; 2; "Start Date"; ->[Treatment_Plans]Start_Date; "")
WebFORM_AddFieldValue($web_form; 2; "End Date"; ->[Treatment_Plans]End_Date; "")

// Add hidden fields
WebFORM_AddHiddenRawValue($web_form; "treatmentPlanID"; String($plan_id))
WebFORM_AddHiddenRawValue($web_form; "sid"; String([Treatment_Plans]Student_Key))

// Generate and return HTML
$html := WebFORM_GenerateHTML($web_form; $isEditable)
WebFORM_Clear($web_form)
```

**Template calls method:**
```html
<form action="/students/treatment_plans" method="post">
    <input type="hidden" name="CSRF_Token" 
           value="<!--#4DTEXT Sessions_Get_CSRFToken(WEB_t_sessionID)-->">
    
    <!--#4DHTML woTreatmentPlans_Detail([Treatment_Plans]ID)-->
</form>
```

**Generated HTML output:**
```html
<table class="formTable">
    <tr>
        <td class="formLabel">Plan Name:</td>
        <td class="formData">
            <input type="text" name="Treatment_Plans_Name" 
                   value="Behavioral Support Plan" size="50">
        </td>
    </tr>
    <tr>
        <td class="formLabel">Start Date:</td>
        <td class="formData">
            <input type="date" name="Treatment_Plans_Start_Date" 
                   value="2025-01-15">
        </td>
    </tr>
    <!-- More fields... -->
    <input type="hidden" name="treatmentPlanID" value="12345">
    <input type="hidden" name="sid" value="67890">
</table>
```

### Direct HTML Generation

**Building HTML strings:**
```4d
// woStudent_Header
#DECLARE($student_id : Integer) -> $html : Text

Record_EnsureLoaded_byLongID(->[Student]ID; $student_id)

$html := "<span class='student-name'>"
$html += HTML_Escape([Student]First_Name)+" "
$html += HTML_Escape([Student]Last_Name)
$html += "</span>"
$html += " (ID: "+String([Student]Student_ID)+")"
```

**Template usage:**
```html
<h3>Student: <!--#4DHTML woStudent_Header([Student]Student_ID)--></h3>
```

### List/Table Generation

**Dynamic table from query:**
```4d
// WebSRCHLIST_RenderListAsHTML
#DECLARE($session_id : Text; $listType : Text) -> $html : Text

QUERY([Student]; [Student]District_Key = WEB_l_districtID)
ORDER BY([Student]; [Student]Last_Name; >)

$html := "<table class='dataTable'>"
$html += "<thead><tr>"
$html += "<th>Name</th><th>DOB</th><th>School</th><th>Actions</th>"
$html += "</tr></thead><tbody>"

For each ($student; Records in selection([Student]))
    $html += "<tr>"
    $html += "<td>"+HTML_Escape($student.First_Name)+" "+HTML_Escape($student.Last_Name)+"</td>"
    $html += "<td>"+Date2String($student.DOB; "mm/dd/yyyy")+"</td>"
    $html += "<td>"+HTML_Escape($student.School_Name)+"</td>"
    $html += "<td><a href='/students/detail?id="+String($student.ID)+"'>View</a></td>"
    $html += "</tr>"
End for each

$html += "</tbody></table>"
```

---

## Template Reusability

### Include Files

**Common includes:**

| Include File | Purpose |
|--------------|---------|
| `/includes/page_start.html` | Full page header with navigation |
| `/includes/page_end.html` | Page footer and closing tags |
| `/includes/inc_page_header.html` | Header without navigation |
| `/includes/inc_page_footer.html` | Simple footer |
| `/includes/header.html` | Top banner with logo |
| `/includes/tab_bar.html` | Main tab navigation |
| `/includes/inc_navigation.html` | Left sidebar navigation |
| `/includes/inc_footer.html` | Copyright/version footer |
| `/includes/_Custom_Stylesheet_elements.html` | District-specific CSS overrides |

**Usage pattern:**
```html
<!-- Simple template -->
<!--#4DHTML WebUtil_Include("/includes/inc_page_header.html")-->

<h3>My Page Content</h3>
<p>Content goes here...</p>

<!--#4DHTML WebUtil_Include("/includes/inc_page_footer.html")-->
```

### Template Fragments

**Sub-page includes:**
```
main/student/tab_details/
├── ieps.html                      # IEP list for student
├── treatment_plans_list.html     # Treatment plan list
├── goals_objectives_list.html    # Goals and objectives
└── studentDocuments.html         # Document list
```

**Parent tab template:**
```html
<!--#4DHTML WebUtil_PageStart("Student Details")-->

<h3>Student: <!--#4DHTML woStudent_Header([Student]Student_ID)--></h3>

<!--#4DHTML woStudent_ShowDetails_TabBar("ieps")-->

<!-- Include the appropriate tab content -->
<!--#4Dif (WebSys_GetParam("tab") = "ieps")-->
    <!--#4DHTML WebUtil_Include("/main/student/tab_details/ieps.html")-->
<!--#4Delse-->
    <!--#4DHTML WebUtil_Include("/main/student/tab_details/treatment_plans_list.html")-->
<!--#4Dendif-->

<!--#4DHTML WebUtil_PageEnd-->
```

---

## Special Template Types

### Email Templates

**Location:** `Resources/WEB_Private/TEMPLATES/`

**Structure:**
- `SummaryEmail_HTML_Start.txt` - Email header
- `SummaryEmail_HTML_End.txt` - Email footer

**Email generation:**
```4d
// Build email HTML
$email_html := ""
$email_html += Document2Text(Get 4D folder(Current resources folder)+"WEB_Private/TEMPLATES/SummaryEmail_HTML_Start.txt")

$email_html += "<h2>Daily Summary Report</h2>"
$email_html += "<p>Date: "+Date2String(Current date; "mm/dd/yyyy")+"</p>"

// Add table of data
$email_html += "<table class='a'>"
$email_html += "<tr><th>Student</th><th>Treatment</th><th>Status</th></tr>"
// ... populate rows ...
$email_html += "</table>"

$email_html += Document2Text(Get 4D folder(Current resources folder)+"WEB_Private/TEMPLATES/SummaryEmail_HTML_End.txt")

// Send email
SMTP_Send($to_email; $from_email; "Daily Summary"; $email_html; "text/html")
```

### Calendar Templates

**Monthly calendar template:**
```
Resources/WEB_Private/TEMPLATES/MonthlyCalendar.txt
```

**Template structure:**
```html
<table class="calendar">
    <tr>
        <th>Sunday</th>
        <th>Monday</th>
        <!-- ... -->
    </tr>
    <!--WEEK_ROW-->
    <tr>
        <!--DAY_CELL-->
        <td class="<!--DAY_CLASS-->">
            <div class="day-number"><!--DAY_NUMBER--></div>
            <!--DAY_CONTENT-->
        </td>
        <!--/DAY_CELL-->
    </tr>
    <!--/WEEK_ROW-->
</table>
```

**Processing:**
```4d
$template := Document2Text($template_path)

// Replace placeholders
$template := Replace string($template; "<!--MONTH_NAME-->"; $month_name)
$template := Replace string($template; "<!--YEAR-->"; String($year))

// Build week rows
$week_html := ""
For ($day; 1; Days in month($date))
    $cell_html := $day_cell_template
    $cell_html := Replace string($cell_html; "<!--DAY_NUMBER-->"; String($day))
    $cell_html := Replace string($cell_html; "<!--DAY_CONTENT-->"; $day_data{$day})
    $week_html += $cell_html
End for

$template := Replace string($template; "<!--WEEK_ROW-->...<!--/WEEK_ROW-->"; $week_html)
```

---

## Best Practices

### 1. Template Organization

✅ **DO:**
- Group related templates in folders (`admin/`, `reports/`, `main/student/`)
- Use descriptive filenames (`treatment_plan_detail.html`, not `page7.html`)
- Keep includes in dedicated `/includes/` folder
- Separate page templates from fragment includes

❌ **DON'T:**
- Mix business logic into templates (keep in 4D methods)
- Create deep nesting (max 2-3 levels of includes)
- Duplicate layout code across templates

### 2. Performance

✅ **DO:**
- Cache static template content via `WebCache_GetTextOfFile()`
- Minimize database queries in rendering methods
- Use `WebFORM` for form generation (optimized)
- Load JavaScript at end of `<body>` when possible

❌ **DON'T:**
- Execute heavy queries in template tags
- Include large JavaScript libraries on every page
- Use synchronous AJAX in page load

### 3. Security

✅ **DO:**
- Always include CSRF tokens in forms
- Use CSP nonces for inline scripts/styles
- Check authorization before rendering sensitive UI
- HTML-escape all user-generated content
- Validate all form inputs server-side

❌ **DON'T:**
- Trust client-side validation alone
- Expose sensitive data in HTML comments
- Use `eval()` or `innerHTML` with user data
- Skip CSRF validation on "safe" forms

### 4. Maintainability

✅ **DO:**
- Comment complex template logic
- Use consistent naming conventions
- Version CSS/JS filenames for cache-busting
- Document custom 4D tags/methods
- Keep templates DRY (Don't Repeat Yourself)

❌ **DON'T:**
- Hardcode configuration values in templates
- Use inline styles (use CSS classes)
- Create overly complex conditional logic
- Mix multiple concerns in one template

### 5. Accessibility

✅ **DO:**
- Include WCAG stylesheet (`/EEM/wcag.css`)
- Use semantic HTML (`<nav>`, `<main>`, `<article>`)
- Add ARIA attributes for dynamic content
- Provide alt text for images
- Ensure keyboard navigation works

❌ **DON'T:**
- Rely on color alone for information
- Create keyboard traps
- Use placeholder as label replacement
- Disable zoom or text resizing

---

## Debugging Templates

### Common Issues

**1. Tag not processing:**
```html
<!-- WRONG: Missing closing comment -->
<!--#4DHTML WebUtil_PageStart("Title")

<!-- CORRECT: -->
<!--#4DHTML WebUtil_PageStart("Title")-->
```

**2. Variable not found:**
```html
<!-- Check variable scope - must be process or interprocess -->
<!--#4DTEXT WEB_t_pageTitle-->  <!-- ✅ Process variable WEB_t_pageTitle -->
<!--#4DTEXT vPageTitle-->        <!-- ❌ Local variable not accessible -->
```

**3. Method returns no content:**
```4d
// WRONG: Method doesn't return value
// woMyMethod
$html := "<p>Content</p>"
// Missing: $0 := $html

// CORRECT:
#DECLARE() -> $html : Text
$html := "<p>Content</p>"
```

**4. Include path incorrect:**
```html
<!-- WRONG: Relative path without leading slash -->
<!--#4DHTML WebUtil_Include("includes/header.html")-->

<!-- CORRECT: Absolute path from WEB_Private root -->
<!--#4DHTML WebUtil_Include("/includes/header.html")-->
```

### Debugging Techniques

**1. Add debug output:**
```4d
// In method called from template
$html := "<p>DEBUG: Student ID = "+String($student_id)+"</p>"
$html += "<p>DEBUG: Query found "+String(Records in selection([Student]))+" records</p>"
```

**2. Check 4D method logs:**
```4d
// Add logging to methods
Logging_AddToLog("woStudent_Detail called with ID: "+String($student_id))
```

**3. View generated HTML:**
- Use browser "View Source" to see final HTML
- Look for malformed tags or missing content
- Check browser console for JavaScript errors

**4. Test methods in debugger:**
```4d
// Run method directly in 4D with test parameters
$result := woStudent_Detail(12345)
ALERT($result)
```

---

## Migration & Updates

### Updating Asset Versions

**When CSS/JS files change:**

1. **Rename files with new version:**
   ```
   ezedmed_style-2025-10-15.css → ezedmed_style-2025-01-26.css
   ezedmed_script-2026-03-17.js → ezedmed_script-2025-01-26.js
   ```

2. **Update all template references:**
   ```bash
   # Find all files referencing old version
   grep -r "ezedmed_style-2025-10-15.css" Resources/WEB_Private/
   ```

3. **Update include templates:**
   - `Resources/WEB_Private/includes/page_start.html`
   - `Resources/WEB_Private/includes/inc_page_header.html`

4. **Test across browsers** to ensure cache-busting works

### Adding New Templates

**1. Create template file:**
```html
<!-- Resources/WEB_Private/admin/new_feature.html -->
<!--#4DHTML WebUtil_PageStart("New Feature")-->

<h3>New Feature Page</h3>

<!--#4DHTML woNewFeature_ShowDetails-->

<!--#4DHTML WebUtil_PageEnd-->
```

**2. Create corresponding 4D method:**
```4d
// woNewFeature_ShowDetails
#DECLARE() -> $html : Text

$html := "<p>Feature content goes here</p>"
```

**3. Add routing:**
```4d
// In aa_Shell_Startup_WebAction
Case of
    : ($url = "/admin/new_feature")
        $page_path := "admin/new_feature.html"
End case
```

**4. Add navigation link:**
```html
<!-- In includes/inc_navigation.html -->
<li><a href="/admin/new_feature">New Feature</a></li>
```

---

## Related Documentation

- [Incoming Web Request Architecture](incoming-web-request-arch.md) - Complete HTTP request flow
- [Outbox Reporting](outbox-reporting.md) - Report generation mechanisms
- [4D Coding Style](4d-coding-style.md) - General coding conventions

---

## Summary

The web template architecture provides:

✅ **Template-based rendering** with 4D server-side processing  
✅ **Component composition** via includes for reusable layouts  
✅ **Dynamic content generation** through method execution tags  
✅ **Security features** (CSRF tokens, CSP nonces, authorization checks)  
✅ **Asset separation** (private templates vs. public static files)  
✅ **Cache-busting strategy** via versioned filenames  
✅ **Flexible rendering** (WebFORM components and direct HTML generation)  
✅ **Conditional rendering** based on user permissions and state  

The system enables rapid development of secure, maintainable web pages with clear separation between presentation (templates), logic (4D methods), and assets (static files).
