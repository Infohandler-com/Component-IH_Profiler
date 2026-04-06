# GitHub Copilot Instructions - ezEdMed (EEM-KY)

This is a **4D-based web application** for special education service/treatment management, claims processing, and state reporting for Kentucky school districts.

---

## Core Architecture

### Platform & Stack
- **Backend**: 4D Server v19+ (Project mode)
- **Reporting**: PHP scripts (fpdf, PhpSpreadsheet, PhpWord) in `Resources_PHP/`
- **Web Server**: 4D's built-in web server (no external web framework)
- **Frontend**: Server-rendered HTML templates in `Resources/WEB_Private/`, static assets in `Resources/WEB_Public/`
- **Data**: 4D Datastore (ORDA) with entity/class extensions
- **Testing**: Custom xUnit-style framework with action-based dispatchers

### Project Structure
```
Project/
  Sources/
    Classes/          # ORDA entity extensions (e.g., IEPsEntity.4dm)
    DatabaseMethods/  # onStartup, onWebConnection, onWebAuthentication
    Methods/          # Business logic (wa* methods are web action handlers)
    Forms/            # 4D forms (rarely used - web app)
    TableForms/       # Table-specific forms
    Triggers/         # Database triggers
Components/           # Reusable 4D projects (IH_WebShell, IH_Core, etc.)
Resources/
  WEB_Private/        # HTML templates with 4D tags (e.g., <!--#4DTEXT-->)
  WEB_Public/         # Static assets (CSS, JS, images)
  Config/             # Environment-specific configs (PRODUCTION, TEST, TRAINING)
Resources_PHP/        # PHP scripts for PDF/Excel generation
IH_Config/            # Runtime config files
WEB_Outbox/           # Generated report storage
```

**CRITICAL**: Files in `/Components` and `/Plugins` are external projects - do not modify without explicit permission.

---

## Key Subsystems

### 1. Web Request Routing
**Entry**: `onWebConnection.4dm` → `aa_OnWebConnection.4dm` → `WebConnect_Initialize` → `WebConnect_HandleRequest`

**Route Registration**: `aa_Shell_Startup_WebAction.4dm` (called during startup)
```4d
$router := cs.IH_WebShell.WebURLRouter.new()
$router.get("/students/show"; "waStudents_showOne")
$router.post("/students/demographics"; "waStudents_Demographics")
```

**URL Callback Methods**: Methods named `wa*` (e.g., `waMain_HandleRequest`, `waAdmin_MainPage`)
- Accept: `(url: Text; hasAuthorized: Boolean; httpRequestMethod: Text)`
- See [incoming-web-request-arch.md](/.github/reference/incoming-web-request-arch.md) for complete flow

### 2. Background Processing (Files4Import)
**FTP Watcher**: Scans district FTP folders for uploaded files (CSV, SIS exports)
- Config: `Resources/Config/{ENV}/Files4Import Folder Watcher Locations.txt`
- Methods: `Files4Import_FetchUploadedFiles`, `Files4Import_AddFileToProcess`, `Files4Import_IMP_ProcessAll`
- Scheduled via `IH_WebShell_Daemon_Maintenance` (runs nightly at 3am, 5am, 8am)

**Workflow**: Upload → Validate → Queue (`[FilesForImport]` table) → Process → Import

### 3. Asynchronous Reporting (Outbox)
Large reports (PDF, Excel) are queued to `[Outbox]` table for background processing.
- User sees "Pending" → "Completed" status in their outbox
- Files stored in `WEB_Outbox/` with `{outbox}` token in path
- PHP execution: `PHP EXECUTE($phpScript; $input; $output; $errors)`
- See [outbox-reporting.md](/.github/reference/outbox-reporting.md)

### 4. Session Management
- Cookie: `sessionID` (validated via `Sessions_GetUserID`)
- Session data: `Sessions_SetValue(sessionID; key; value)` / `Sessions_GetValue`
- User context: `WEB_l_UserID`, `WEB_l_districtID`, `WEB_o_userAuthorizations`
- CSRF: Token validation for POST requests

### 5. Component Access
**IH_WebShell** (most common):
- `cs.IH_WebShell.WebURLRouter` - URL routing
- `cs.IH_WebShell.Cookie` - Cookie management
- Component methods: Direct call (e.g., `Shell_GetEnvironmentType()`)

**Other Components**: `IH_Core`, `IH_Log`, `IH_Profiler`, `FileFolder_Utils`, etc.

---

## Development Patterns

### 4D Language Specifics (CRITICAL)
- **Never edit `//%attributes` line** in method files
- Use `:=` for assignment, NOT `=`
- Use `;` for parameter separation, NOT `,`
- Local vars: `$varName` | Declared: `var $x : Integer` or `#DECLARE($x : Integer)`
- No semicolons at end of lines
- Date literals: `!2025-01-09!` | Time: `?14:30:00?`
- See [4d-coding-style.md](/.github/reference/4d-coding-style.md) for complete guide

### Web Action Handler Pattern
```4d
//%attributes = {"invisible":true,"shared":true,"preemptive":"capable"}
// wa<Module>_<Action> (url; hasAuthorized; httpRequestMethod)
#DECLARE($url : Text; $hasAuthorized : Boolean; $httpRequestMethod : Text)

Profiler_START(Current method name)

Case of
: (Not($hasAuthorized))
    WebCore_BadLogin($url)
: ($httpRequestMethod="GET")
    // Handle GET
    WebConnect_SendPage("/path/to/template.html")
: ($httpRequestMethod="POST")
    // Handle POST, process form data
    WebConnect_SendRedirect("/somewhere")
End case
```

### Entity Extensions
Classes in `Project/Sources/Classes/` extend ORDA entities:
```4d
Class extends Entity  // e.g., IEPsEntity.4dm, GoalsEntity.4dm

Function Get_Date_Of_Latest_Measurement() -> $result : Date
    $result := ds.GraphingGoal_DataPoint\
        .query("goal.iep.ID=:1"; This.ID)\
        .max("Measurement_Date")
```

### Unit Testing
Test methods follow `<Module>__UnitTests` naming:
```4d
#DECLARE($action : Text)

If (Count parameters = 0)
    UnitTest_Setup_EEM  // Launch test runner
    return
End if

Case of
: ($action = "RunTests")
    UnitTest_RunTest("TestCase1")
: ($action = "TestCase1")
    UnitTest_AssertEqualLongint(expected; actual; "description")
End case
```
See [unit-testing.md](/.github/reference/unit-testing.md)

### Web Templates
HTML files in `Resources/WEB_Private/` use 4D tags:
```html
<!--#4DTEXT $studentName-->
<!--#4DINCLUDE /includes/page_start.html-->
<!--#4DLOOP $students-->
  <tr><td><!--#4DTEXT $students[$i].name--></td></tr>
<!--#4DENDLOOP-->
```
See [web-templates.md](/.github/reference/web-templates.md)

---

## Common Workflows

### Adding a New Web Action
1. Create method: `wa<Module>_<Action>.4dm` in `Project/Sources/Methods/`
2. Register route in `aa_Shell_Startup_WebAction.4dm`:
   ```4d
   $router.get_and_post("/path"; "wa<Module>_<Action>")
   ```
3. Create template: `Resources/WEB_Private/<module>/<action>.html`
4. Handle GET/POST in method using `Case of` pattern

### Adding Background Job
1. Create method for job logic (preemptive-capable recommended)
2. Schedule in `IH_WebShell_Daemon_Maintenance` or `IH_WebShell_Daemon_Regular`
3. Use `QueuedTasks_Add` for delayed execution

### Generating Report via Outbox
```4d
var $outboxID : Integer
$outboxID := Outbox_AddItem({
    user_key: $userID;
    description: "Student Audit Report";
    codeToExecute: "Reports_Generate_StudentAudit("+String($studentID)+")";
    fileName: "student_audit.pdf"
})
```

---

## Reference Documentation

| Document | Purpose |
|----------|---------|
| [PRD.md](/PRD.md) | Product requirements, features, architecture overview |
| [4d-coding-style.md](/.github/reference/4d-coding-style.md) | **Required reading** - 4D syntax, conventions, patterns |
| [incoming-web-request-arch.md](/.github/reference/incoming-web-request-arch.md) | Complete HTTP request flow (authentication → routing → response) |
| [outbox-reporting.md](/.github/reference/outbox-reporting.md) | Asynchronous job queue and PHP report generation |
| [unit-testing.md](/.github/reference/unit-testing.md) | xUnit-style testing framework and patterns |
| [web-templates.md](/.github/reference/web-templates.md) | HTML template syntax and 4D tag usage |

### Instruction Files

The following instruction files define coding, testing, catalog, forms, and workflow guidance for this repository:

| Instruction | Purpose |
|----------|---------|
| [4d.catalog.instructions.md](/.github/instructions/4d.catalog.instructions.md) | Catalog and schema editing rules for `catalog.4DCatalog` changes |
| [4d.errors.instructions.md](/.github/instructions/4d.errors.instructions.md) | Handling known 4D syntax-checker and dependency false positives |
| [4d.forms.instructions.md](/.github/instructions/4d.forms.instructions.md) | Form architecture, class binding, and form event handling patterns |
| [4d.instructions.md](/.github/instructions/4d.instructions.md) | Core 4D language conventions and coding standards |
| [4dtest.md.instructions.md](/.github/instructions/4dtest.md.instructions.md) | Test execution instructions using `tool4d` |
| [Create-prd.instructions.md](/.github/instructions/Create-prd.instructions.md) | Product Requirements Document generation workflow |
| [prime.instructions.md](/.github/instructions/prime.instructions.md) | Initial project priming and context-loading workflow |
| [4d.outbox-background.instructions.md](/.github/instructions/4d.outbox-background.instructions.md) | Outbox and background processing guardrails |
| [4d.qa-gates.instructions.md](/.github/instructions/4d.qa-gates.instructions.md) | Definition of done and QA gates for 4D changes |
| [4d.web-handlers.instructions.md](/.github/instructions/4d.web-handlers.instructions.md) | Web action handler security and routing guardrails |
| [4d.security-config.instructions.md](/.github/instructions/4d.security-config.instructions.md) | Security and configuration guardrails |
| [repository-boundaries.instructions.md](/.github/instructions/repository-boundaries.instructions.md) | Repository edit boundaries and safety rules |


---

## Environment & Configuration

**Environments**: PRODUCTION, TEST, TRAINING
- Current env: `Shell_GetEnvironmentType()` (returns Text)
- Config files: `Resources/Config/{ENV}/`
- Runtime config: `CONFIG_GetLocalValue(section; key; default)`

**Startup Flow**:
1. `onStartup.4dm` → `aa_Shell_Startup`
2. Load preferences: `Pref_LoadPreferences`
3. Web setup: `IH_Shell_Startup_WEB` → `aa_Shell_Startup_WebAction`
4. Start daemons: `IH_WebShell_Daemon_*`

---

## Critical Conventions

1. **Read-only by default**: `READ ONLY(*)` set during web connection init
2. **Profiling**: Always use `Profiler_START(Current method name)` / `Profiler_STOP`
3. **Logging**: `Log_INFO`, `Log_ERROR`, `LogNamed_AppendToFile` for custom logs
4. **Error handling**: `OnErr_Install_Handler("OnErr_MAIN_ErrorHandler")`
5. **Security**: Check authorizations via `WEB_o_userAuthorizations` object
6. **Database methods**: Minimal logic - delegate to `aa_*` methods


