# Incoming Web Request Architecture

**Last Updated:** 2026-01-26

---

## Overview 📋

ezEdMed (EEM) uses 4D's built-in web server to handle HTTP requests. The system implements a layered architecture with authentication, session management, routing, and request handling components. This document outlines the complete flow from incoming HTTP request to response generation.

---

## Request Flow Diagram 🔄

```
┌─────────────────────────────────────────────────────────────┐
│  1. CLIENT (Browser)                                        │
│     Sends HTTP GET/POST request                             │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│  2. 4D WEB SERVER                                           │
│     - Receives HTTP request                                 │
│     - Triggers database method: On Web Authentication       │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│  3. ON WEB AUTHENTICATION                                   │
│     File: onWebAuthentication.4dm                           │
│     - Filters 4dmethod calls (rejects)                      │
│     - Checks for bad URLs                                   │
│     - Returns boolean authorization                         │
└────────────────┬────────────────────────────────────────────┘
                 │ (if authorized)
                 ▼
┌─────────────────────────────────────────────────────────────┐
│  4. ON WEB CONNECTION                                       │
│     File: onWebConnection.4dm → aa_OnWebConnection.4dm      │
│     - Extracts URL, headers, client IP                      │
│     - Handles maintenance mode                              │
│     - Cookie validation                                     │
│     - Session ID extraction                                 │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│  5. INITIALIZATION                                          │
│     Method: WebConnect_Initialize                           │
│     - Loads header, form, URL parameter data (WebSys)       │
│     - Strips query params from URL                          │
│     - Sets process tracking name                            │
│     - Initializes web-specific boolean flags                │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│  6. SESSION & AUTHENTICATION CHECK                          │
│     - Cookie: "sessionID" extracted                         │
│     - Sessions_GetUserID(sessionID) → User ID               │
│     - Load user, district, security permissions             │
│     - CSRF token validation (for POST)                      │
│     - Two-factor authentication (if required)               │
└────────────────┬────────────────────────────────────────────┘
                 │
        ┌────────┴────────┐
        │                 │
        ▼                 ▼
  ┌──────────┐     ┌──────────────┐
  │ No User? │     │ User Logged  │
  │          │     │ In & Valid   │
  └─────┬────┘     └──────┬───────┘
        │                 │
        │                 ▼
        │          ┌─────────────────────────────────────────┐
        │          │  7. AUTHORIZATION SETUP                 │
        │          │     - WEB_o_userAuthorizations created  │
        │          │     - User_SetupAuthorizationVar        │
        │          │     - Set flags: isLoggedIn,            │
        │          │       isTherapist, isAdmin, etc.        │
        │          └──────┬──────────────────────────────────┘
        │                 │
        │                 ▼
        │          ┌──────────────────────────────────────────┐
        │          │  8. ROUTING                              │
        │          │     Method: WebConnect_HandleRequest     │
        │          │     - Serves static files (CSS/JS/images)│
        │          │     - Routes to WebURLRouter (new)       │
        │          │     - Falls back to legacy handlers      │
        │          └──────┬───────────────────────────────────┘
        │                 │
        │                 ▼
        │          ┌─────────────────────────────────────────┐
        │          │  9. URL ROUTER (IH_WebShell Component)  │
        │          │     Class: cs.IH_WebShell.WebURLRouter  │
        │          │     - Routes registered at startup      │
        │          │     - Matches URL pattern to callback   │
        │          │     - Validates authorizations          │
        │          │     - Invokes callback method           │
        │          └──────┬──────────────────────────────────┘
        │                 │
        │                 ▼
        │          ┌─────────────────────────────────────────┐
        │          │  10. CALLBACK METHOD EXECUTION          │
        │          │      Examples:                          │
        │          │      - waUser_EditProfile               │
        │          │      - waStudents_showOne               │
        │          │      - waDashboard                      │
        │          │      - waReports_*                      │
        │          │      Method signature:                  │
        │          │      (url; hasAuthorized; httpMethod)   │
        │          └──────┬──────────────────────────────────┘
        │                 │
        │                 ▼
        │          ┌──────────────────────────────────────────┐
        │          │  11. BUSINESS LOGIC                       │
        │          │      - Process form data (WebSys_GetParam)│
        │          │      - Query database (4D datastore)      │
        │          │      - Generate HTML/JSON/PDF             │
        │          │      - Use template files or builders     │
        │          └──────┬───────────────────────────────────┘
        │                 │
        ▼                 ▼
  ┌─────────────────────────────────────────────────────────┐
  │  12. RESPONSE GENERATION                                │
  │      Methods:                                           │
  │      - WebConnect_SendPage(pageHTML)                    │
  │      - WebConnect_SendText(text)                        │
  │      - WebConnect_SendBlob(->blob; mimeType)            │
  │      - WebConnect_SendRedirect(url)                     │
  │      Uses: WEB SEND TEXT, WEB SEND BLOB, etc.           │
  └────────────────┬────────────────────────────────────────┘
                   │
                   ▼
  ┌─────────────────────────────────────────────────────────┐
  │  13. 4D WEB SERVER                                      │
  │      - Sends HTTP response to client                    │
  │      - Includes headers (cookies, content-type, etc.)   │
  └────────────────┬────────────────────────────────────────┘
                   │
                   ▼
  ┌─────────────────────────────────────────────────────────┐
  │  14. CLIENT (Browser)                                   │
  │      - Receives HTML/JSON/file                          │
  │      - Renders page or processes response               │
  └─────────────────────────────────────────────────────────┘
```

---

## Component Details 🔍

### 1. Database Methods (Entry Points)

#### On Web Authentication
**File:** `Project/Sources/DatabaseMethods/onWebAuthentication.4dm`

**Purpose:** Pre-filter requests before full processing.

**Key Actions:**
- Rejects `4dmethod` calls (security)
- Blocks direct access to certain resources
- Returns `True` to allow processing or `False` to reject
- Does NOT perform user authentication (that's in On Web Connection)

**Parameters:**
```4d
$1: URL (Text)
$2: HTTP header (Text)
$3: Client IP (Text)
$4: Server IP (Text)
$5: Username (Text) - typically empty
$6: Password (Text) - typically empty
$0: Boolean (authorized to proceed)
```

---

#### On Web Connection
**File:** `Project/Sources/DatabaseMethods/onWebConnection.4dm` → calls `aa_OnWebConnection.4dm`

**Purpose:** Main entry point for web request processing.

**Key Actions:**
1. **Normalize URL** - Clean up dynamic parts for logging
2. **Maintenance Mode Check** - Reject if system in maintenance (except `/heartbeat`)
3. **Initialize Request Context:**
   - `WebConnect_Initialize($url)` - loads headers, params, cookies
   - Extracts session ID from cookie: `Cookie_GetValueFromRequest("sessionID")`
4. **Session Validation:**
   - `Sessions_GetUserID(sessionID)` - get user ID from session
   - Validate session hasn't expired
   - Load user record and permissions
5. **Security Checks:**
   - Cookie validation (`cookieTest`)
   - CSRF token validation (POST requests)
   - Two-factor authentication (if enabled)
6. **Authorization Object Setup:**
   - `WEB_o_userAuthorizations` (UserAuthorizations class)
   - Sets flags: `isLoggedIn`, `isTherapist`, `isAdmin`, etc.
7. **Hand-off to Routing:**
   - `WebConnect_HandleRequest($url; $hasAuthorized; $httpMethod)`

**Important Variables Set:**
```4d
WEB_t_sessionID         // Session identifier
WEB_l_UserID            // Logged-in user ID
WEB_l_UserID_ActingAs   // "Act As" user ID (if impersonating)
WEB_l_districtID        // Current district ID
WEB_b_userIsTherapist   // Is therapist?
WEB_b_isSysAdmin        // Is system admin?
WEB_b_isAdminOfSometype // Is any type of admin?
WEB_o_userAuthorizations // Authorization object for routing
```

---

### 2. Initialization

#### WebConnect_Initialize
**File:** `Project/Sources/Methods/WebConnect_Initialize.4dm`

**Purpose:** Prepare system variables and parse request data.

**Key Actions:**
- Load HTTP headers into arrays (`WebSys_LoadData`)
- Parse URL parameters
- Parse POST form data
- Strip query string from URL (for routing)
- Initialize web-specific boolean flags
- Set process tracking name

**Returns:** Cleaned URL (without parameters)

---

### 3. Session Management

#### Session Storage
- **Component:** IH_Core (session management)
- **Cookie Name:** `sessionID`
- **Session Functions:**
  - `Sessions_GetUserID(sessionID)` - Get logged-in user
  - `Sessions_GetUserID_ActingAs(sessionID)` - Get "act as" user (impersonation)
  - `Sessions_GetValue(sessionID; key)` - Get session variable
  - `Sessions_SetNonPersistentValue(sessionID; key; value)` - Set temp value
  - `Sessions_SetPersistentValue(sessionID; key; value)` - Set persisted value
  - `Sessions_Get_CSRFToken(sessionID)` - Get CSRF token

#### CSRF Protection
- **Token Generation:** `Sessions_Get_CSRFToken(sessionID)`
- **Token Validation:** `WebSys_CSRF_token_MatchsSessin(token; sessionID)`
- **Applied to:** POST requests (form submissions)
- **Method:** Token embedded in forms, validated on submission

---

### 4. Routing System

#### Modern Router (IH_WebShell Component)

**Class:** `cs.IH_WebShell.WebURLRouter`

**Registration (Startup):**
Routes are registered in `aa_Shell_Startup_WebAction.4dm` at application startup.

**Registration Methods:**
```4d
$router := cs.IH_WebShell.WebURLRouter.new()

// Set default authorization requirements
$router.default_authorizations_for_adding_urls({
    required_authorizations: ["isLoggedIn"];
    one_of_authorizations: []
})

// Set default tab/section
$router.default_tab_for_adding_urls("main")

// Register routes
$router.get("/students/show"; "waStudents_showOne")
$router.post("/students/demographics"; "waStudents_Demographics")
$router.get_and_post("/user/editProfile"; "waUser_EditProfile")
```

**Legacy Registration Methods (still in use):**
```4d
Router_AddUrlCallback_GET(urlPattern; callbackMethod; tabName)
Router_AddUrlCallback_POST(urlPattern; callbackMethod; tabName)
```

**Route Processing:**
```4d
$wasHandled := cs.IH_WebShell.WebURLRouter.new(
    WEB_o_userAuthorizations
).process_url($url; $hasAuthorized; $httpRequestMethod)
```

**Route Matching:**
- Exact match: `/students/show`
- Wildcard match: `/students/@` (matches anything starting with `/students/`)
- Method-specific: Separate registration for GET vs POST

**Authorization Checking:**
Router validates user has required authorizations before invoking callback.

---

#### Legacy Routing (fallback)

If the modern router doesn't handle the URL, the system falls back to legacy handlers:

**WebConnect_HandleRequest** checks:
1. Static files (images, CSS, JS, PDFs)
2. Special URLs (logout, policy acceptance, etc.)
3. Legacy route handlers:
   - `webcore@` → `WebCore_HandleRequest` (therapist/teacher pages)
   - `webadmin@` → `WebAdmin_HandleRequest` (admin pages)

---

### 5. URL Callback Methods (Controllers)

#### Standard Signature
All callback methods follow this signature:
```4d
// waMethodName (url; hasAuthorized; httpRequestMethod)
#DECLARE($url : Text; $hasAuthorized : Boolean; $httpRequestMethod : Text)
```

**Parameters:**
- `$url` - Full URL path (e.g., `/students/show`)
- `$hasAuthorized` - Boolean indicating if user is logged in
- `$httpRequestMethod` - Either `HTTP GET method` or `HTTP POST method`

**Common Patterns:**

**1. Authorization Check:**
```4d
Case of
    : (Not($hasAuthorized))
        WebCore_BadLogin($url)
    : ($httpRequestMethod = HTTP POST method)
        // Process form submission
    Else
        // Display page
End case
```

**2. Extract Parameters:**
```4d
$studentId := Num(WebSys_GetParam("id"))
$action := WebSys_GetParam("action")
```

**3. Load Data:**
```4d
Record_EnsureLoaded_byLongID(->[Student]ID; $studentId)
```

**4. Generate Response:**
```4d
$html := HTML_BuildPage(...)
WebConnect_SendPage($html)
```

---

#### Example Callback Methods

**User Profile:**
- `/user/editProfile` → `waUser_EditProfile`
- Displays user's own profile for editing

**Student Management:**
- `/students/show?id=123` → `waStudents_showOne`
- Displays single student detail page

**Dashboard:**
- `/dashboard` → `waDashboard`
- District admin dashboard with metrics

**Reports:**
- `/reports/therapistprvdschd` → `waReports_ThrpistTrmntPrvdSchd`
- Generate therapist service report

---

### 6. Request Data Access

#### WebSys Component Functions

**URL Parameters:**
```4d
$value := WebSys_GetParam("paramName")
$count := WebSys_GetParamCount
$name := WebSys_GetParamNameAtPos($index)
$value := WebSys_GetParamValueAtPos($index)
WebSys_SetParam("paramName"; "value") // Modify for downstream
```

**HTTP Headers:**
```4d
$value := WebSys_GetHeaderValue("Header-Name")
$clientIP := WebSys_GetHeaderValue("X-Forwarded-For")
$host := WebSys_GetHeaderValue("Host")
```

**POST Form Data:**
Automatically parsed and accessible via `WebSys_GetParam()`

**Cookies:**
```4d
$value := Cookie_GetValueFromRequest("cookieName")
Cookie_AddToResponse("cookieName"; "value"; $expirationDate)
```

---

### 7. Authorization Object

#### UserAuthorizations Class
**Component:** IH_WebShell
**Class:** `cs.IH_WebShell.UserAuthorizations`

**Setup:**
```4d
WEB_o_userAuthorizations := User_SetupAuthorizationVar
WEB_o_userAuthorizations.set_authorization("isLoggedIn"; True)
WEB_o_userAuthorizations.set_authorization("isTherapist"; $isTherapist)
```

**Common Authorizations:**
- `isLoggedIn` - User has valid session
- `isTherapist` - User is a therapist/provider
- `isTeacher` - User is a teacher
- `isSystemAdmin` - User is system administrator
- `isDistrictAdmin` - User is district administrator
- `isAdminOfSomeType` - User has any admin role
- `isInfoHandlerEmployee` - InfoHandler staff member
- `isRestrictedSystemAdmin` - Limited system admin

**Used by Router:**
Router checks authorizations before invoking callback methods.

---

### 8. Response Generation

#### Response Methods

**Send HTML Page:**
```4d
WebConnect_SendPage($htmlContent)
// Uses: WEB SEND TEXT with text/html MIME type
```

**Send Plain Text:**
```4d
WebConnect_SendText($textContent)
// Uses: WEB SEND TEXT
```

**Send Binary File (PDF, images, etc.):**
```4d
WebConnect_SendBlob(->$blobVariable; $mimeType)
// Uses: WEB SEND BLOB
```

**Send Redirect:**
```4d
WebConnect_SendRedirect($newURL)
// Sets Location header and 302 status
```

**Send JSON:**
```4d
$json := JSON Stringify($object)
WebConnect_SendPage($json) // with appropriate content-type
```

**Cache-aware File Serving:**
```4d
WebCache_SendFile($url; $filePath)
// Handles ETag, Last-Modified headers for caching
```

---

### 9. Page Generation

#### Template-based HTML

**Template Files:**
- Located in: `Resources/WEB_Private/` and `Resources/WEB_Public/`
- Extensions: `.html`, `.htm`
- Use 4D tags: `<!--#4DSCRIPT/MethodName-->`

**Template Processing:**
```4d
$html := WebCache_GetTextOfFile("main/student_detail.html")
$html := Replace string($html; "<!--#STUDENTNAME#-->"; [Student]Full_Name)
WebConnect_SendPage($html)
```

#### Dynamic HTML Generation

**Using WebFORM (Form Builder):**
```4d
$webFormObj := WebFORM_Start
WebFORM_AddHiddenValue($webFormObj; "id"; String([Student]ID))
WebFORM_AddHiddenRawValue($webFormObj; "CSRF_Token"; $csrfToken)
$formHTML := WebFORM_End($webFormObj; "/students/save"; HTTP POST method)
```

**Building HTML Directly:**
```4d
$html := "<div class='student-card'>"
$html += "<h2>"+[Student]Full_Name+"</h2>"
$html += "<p>Grade: "+String([Student]Grade)+"</p>"
$html += "</div>"
WebConnect_SendPage($html)
```

---

### 10. Static File Serving

**File Types:**
- Images: `.gif`, `.jpg`, `.png`, `.svg`
- Stylesheets: `.css`
- Scripts: `.js`
- Documents: `.pdf`, `.doc`, `.docx`

**Locations:**
1. `Resources/WEB_Public/` - Publicly accessible
2. `Resources/WEB_Private/` - Requires authentication

**Serving Logic:**
```4d
If (File_DoesExist(Shell_GetFolder_WebPublic + $documentPath))
    $documentPath := Shell_GetFolder_WebPublic + $documentPath
Else
    $documentPath := Shell_GetFolder_WebPrivate + $documentPath
End if

If ($url = "@css") | ($url = "@.js")
    WebCache_SendFile($url; $documentPath) // With caching
Else
    DOCUMENT TO BLOB($documentPath; $blob)
    WebConnect_SendBlob(->$blob; File_DeriveMimeTypeFromName($documentPath))
End if
```

---

### 11. Error Handling

#### Bad Login / Unauthorized
```4d
WebCore_BadLogin($url)
// Redirects to login page with original URL as redirect target
```

#### Error Pages
```4d
$errorPage := WebError_GetErrorPage("Alert"; $errorMessage)
WebConnect_SendPage($errorPage)
```

**Error Types:**
- `"Alert"` - General error message
- `"BadURL"` - Invalid URL requested
- `"NotFound"` - 404 page

#### HTTP Status Codes
```4d
WebSys_SetHTTPHeader("X-STATUS"; "404 Not Found")
WebSys_SetHTTPHeader("X-STATUS"; "302 Found") // Redirect
```

---

### 12. Security Features

#### CSRF Protection
- **Token Generation:** Unique per session
- **Embedding:** Hidden form field `CSRF_Token`
- **Validation:** On POST, compares submitted token to session token
- **Rejection:** Bad token → error page, logged

#### Cookie Validation
- **Test Cookie:** `cookieTest` set on login page
- **Validation:** Must be present to access system
- **Purpose:** Ensure browser accepts cookies

#### Session Timeout
- **Tracked:** Last access time updated on each request
- **Expiration:** Configurable timeout period
- **Enforcement:** `Sessions_IsExpired()` check

#### IP Tracking
- **Recorded:** Client IP from headers (`X-Forwarded-For`, `client-ip`)
- **Logging:** All requests logged with user ID and IP
- **Usage:** Audit trail, security analysis

#### "Act As" (Impersonation)
- **Feature:** Admins can impersonate other users
- **Tracking:** `WEB_l_UserID` (logged-in) vs `WEB_l_UserID_ActingAs` (acting as)
- **Audit:** All actions logged with both IDs
- **Permissions:** Acting-as user's permissions apply

---

## Configuration & Settings ⚙️

### Web Server Settings
**File:** `Settings/settings.4DSettings`

Key settings:
- Port: 80/443
- Max concurrent connections
- Session timeout
- Static file caching

### Startup Initialization
**Method:** `aa_Shell_Startup_WebAction` (called from `IH_Shell_Startup_WEB`)

**Actions:**
1. Register URL routes (`Router_AddUrlCallback_*`)
2. Register search lists (`WebSRCHLIST_RegisterList`)
3. Register custom reports (`WebCUSTRPT_RegisterReport`)
4. Set default authorizations for route groups

---

## Debugging & Logging 🐛

### Request Logging
```4d
LogNamed_AppendToFile("Page URL Requests - HTML"; 
    $http_method + " " + $url + " [" + String(WEB_l_UserID) + "]")
```

**Log Files:**
- `Logs/Page URL Requests - HTML.txt` - All HTML page requests
- `Logs/Page URL Requests - OTHER.txt` - Static files (CSS, JS, images)
- `Logs/Page URL Requests - Maint Mode.txt` - Requests during maintenance mode

### Profiling
```4d
Profiler_START(Current method name)
// ... method code ...
Profiler_STOP(Current method name)
```

Generates performance metrics for method execution.

### Error Logging
```4d
Log_ERR("Error message")
Log_ERR_CRITICAL("Critical error"; "Context")
Log_INFO_FORCED("Important info")
```

---

## Common Patterns & Best Practices ✅

### 1. Always Check Authorization
```4d
Case of
    : (Not($hasAuthorized))
        WebCore_BadLogin($url)
        return
    // ... rest of logic
End case
```

### 2. Validate Input Parameters
```4d
$studentId := Num(WebSys_GetParam("id"))
If ($studentId <= 0)
    $error := "Invalid student ID"
    WebConnect_SendPage(WebError_GetErrorPage("Alert"; $error))
    return
End if
```

### 3. Use Profiler for Performance
```4d
Profiler_START(Current method name)
// ... method code ...
Profiler_STOP(Current method name)
```

### 4. CSRF Token in Forms
```4d
WebFORM_AddHiddenRawValue($formObj; "CSRF_Token"; 
    Sessions_Get_CSRFToken(WEB_t_sessionID))
```

### 5. Session Variable Best Practices
- **Non-persistent:** Temporary, cleared on logout
- **Persistent:** Saved across sessions (preferences)

```4d
Sessions_SetNonPersistentValue(WEB_t_sessionID; "currentTab"; "demographics")
Sessions_SetPersistentValue(WEB_t_sessionID; "pageSize"; "25")
```

---

## Maintenance Mode 🔧

**Purpose:** Block user access during updates/maintenance

**Implementation:**
```4d
If (WebSys_MaintenanceMode_isActive)
    If ($url = "heartbeat@")
        // Allow heartbeat checks
        $obj.inMaintenanceMode := True
        WEB SEND TEXT(JSON Stringify($obj))
    Else
        // Block all other requests
        WebConnect_SendPage("login_No_Access.html")
    End if
    return
End if
```

**Activation:** Via system configuration or state record

---

## Special URLs 🔗

### Heartbeat
**URL:** `/heartbeat`
**Purpose:** Health check for monitoring systems
**Auth:** InfoHandler staff, sys admins, or special heartbeat sessions
**Response:** JSON with system status

### Logout
**URL:** `/logout`
**Purpose:** End user session
**Action:** Clears session, redirects to login

### Forgot Password
**URL:** `/forgotpassword`
**Auth:** Public (no login required)
**Purpose:** Password reset flow

### AJAX Endpoints
**Pattern:** `/ajax/*`
**Example:** `/ajax/setSchoolCalDay`
**Purpose:** Asynchronous operations without full page reload
**Response:** Typically JSON or minimal HTML

---

## Integration Points 🔌

### Components Used
- **IH_WebShell** - Routing, session management, authorization
- **IH_Core** - Utility functions, data handling
- **IH_Log** - Logging infrastructure
- **IH_WebForm** - HTML form generation

### External Systems
- **4D Web Server** - HTTP request/response handling
- **4D Database** - Data persistence
- **PHP Scripts** - Report generation (PDFs)
- **Background Workers** - Async processing (email, imports)

---

## Summary Flow (Quick Reference) ⚡

```
Request → On Web Authentication (filter) → On Web Connection (main entry)
    → WebConnect_Initialize (parse request)
    → Session Validation (cookie, user, permissions)
    → Authorization Setup (WEB_o_userAuthorizations)
    → WebConnect_HandleRequest (routing dispatcher)
        → Static files (serve directly)
        → WebURLRouter.process_url (modern routes)
        → Legacy handlers (fallback)
    → Callback Method (business logic)
    → Response Generation (HTML/JSON/file)
    → 4D Web Server (send to client)
```

---

## Key Files Reference 📁

| File | Purpose |
|------|---------|
| `onWebAuthentication.4dm` | Pre-filter requests |
| `onWebConnection.4dm` | Entry point delegation |
| `aa_OnWebConnection.4dm` | Main request processing |
| `WebConnect_Initialize.4dm` | Request data parsing |
| `WebConnect_HandleRequest.4dm` | Routing dispatcher |
| `aa_Shell_Startup_WebAction.4dm` | Route registration |
| `wa*.4dm` | URL callback methods (controllers) |
| `WebCore_HandleRequest.4dm` | Legacy core page handler |
| `WebAdmin_HandleRequest.4dm` | Legacy admin page handler |

---

## Notes & Caveats ⚠️

1. **Session ID is critical** - All authenticated requests depend on valid sessionID cookie
2. **CSRF tokens** - Required for POST requests on authenticated pages
3. **Process variables** - Many web-specific variables prefixed with `WEB_*`
4. **Thread safety** - Web requests run in separate processes (preemptive where possible)
5. **Caching** - Static files cached for performance; use cache-busting for updates
6. **Profiling overhead** - Enable profiling only when needed for performance analysis
7. **Legacy vs Modern** - System transitioning from legacy routing to WebURLRouter
8. **Authorization object** - Must be passed to router for authorization checks

---

## Future Improvements 🚀

- Complete migration from legacy routing to WebURLRouter
- RESTful API endpoints (JSON-based)
- GraphQL support for complex queries
- WebSocket support for real-time updates
- API rate limiting and throttling
- OAuth2/OIDC integration for SSO
- Enhanced caching strategies (Redis/Memcached)

---

*This document is a living reference and should be updated as the architecture evolves.*
