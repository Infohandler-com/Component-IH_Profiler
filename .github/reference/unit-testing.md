# Unit Testing Architecture

## Overview

The EEM-KY project uses a custom xUnit-style testing framework adapted for the 4D environment. The architecture follows an **action-based dispatcher pattern** where test methods respond to different action commands to execute test suites, individual test cases, and lifecycle hooks.

**Key Principles:**
- Test methods use a `<Module>__UnitTests` naming convention
- Action dispatcher pattern for test organization
- Self-executing: calling without parameters launches test runner
- Comprehensive assertion library for type-specific validations
- Component-level test integration via `UnitTest_Setup_IHWebShell`

---

## Test Method Structure

### Naming Convention

Test methods follow the pattern:
```
<Module>__UnitTests
```

Examples:
- `HIPPA__UnitTests`
- `Treatments__UnitTests`
- `Audit__UnitTests` (in IH_WebShell component)
- `Cookie__UnitTests` (in IH_WebShell component)

### Action Dispatcher Pattern

All test methods implement a standardized action dispatcher using a `Case of` statement:

```4d
#DECLARE($action : Text)

If (Count parameters = 0)
    UnitTest_Setup_EEM
    return
End if

Case of
    : ($action = "RunTests")
        // Register all test cases
        UnitTest_RunTest("TestCase1")
        UnitTest_RunTest("TestCase2")
        UnitTest_RunTest("TestCase3")
        
    : ($action = "Setup")
        // Initialize test fixtures
        // NOP if no setup required
        
    : ($action = "TearDown")
        // Cleanup after tests
        // NOP if no cleanup required
        
    : ($action = "TestCase1")
        // First test implementation
        UnitTest_AssertEqualLongint(expected; actual; "description")
        
    : ($action = "TestCase2")
        // Second test implementation
        UnitTest_AssertEqualReal(expected; actual)
        
    : ($action = "TestCase3")
        // Third test implementation
        UnitTest_Assert(condition; "assertion message")
End case
```

### Self-Executing Entry Point

When called with **no parameters**, test methods automatically invoke the test suite runner:

```4d
If (Count parameters = 0)
    UnitTest_Setup_EEM  // Launches test dialog
    return
End if
```

This allows developers to run the entire test suite by simply executing the test method without arguments.

---

## Test Discovery & Execution

### Test Suite Registration

Test suites are registered in [UnitTest_Setup_EEM.4dm](../../Project/Sources/Methods/UnitTest_Setup_EEM.4dm):

```4d
UnitTest_Init("all_soft")

// Register project test methods
UnitTest_AddTestCase("Treatments__UnitTests")
UnitTest_AddTestCase("HIPPA__UnitTests")

// Add component tests
UnitTest_Setup_IHWebShell

// Display test runner dialog
UnitTest_ShowDialog
```

**Registration Flow:**
1. `UnitTest_Init("all_soft")` - Initializes test framework
2. `UnitTest_AddTestCase()` - Registers each test method
3. `UnitTest_Setup_IHWebShell` - Adds component tests from IH_WebShell and IH_Core
4. `UnitTest_ShowDialog` - Displays interactive test runner dialog

### Test Execution Flow

```
┌─────────────────────────────────────────┐
│  Developer executes test method         │
│  (no parameters)                        │
└─────────────┬───────────────────────────┘
              │
              v
┌─────────────────────────────────────────┐
│  UnitTest_Setup_EEM                     │
│  - Initializes framework                │
│  - Registers all test cases             │
│  - Shows dialog                         │
└─────────────┬───────────────────────────┘
              │
              v
┌─────────────────────────────────────────┐
│  UnitTest_Dialog (form)                 │
│  - Displays test list                   │
│  - User selects tests to run            │
└─────────────┬───────────────────────────┘
              │
              v
┌─────────────────────────────────────────┐
│  Module__UnitTests("Setup")             │
│  - Initialize test fixtures             │
└─────────────┬───────────────────────────┘
              │
              v
┌─────────────────────────────────────────┐
│  Module__UnitTests("RunTests")          │
│  - Executes UnitTest_RunTest()          │
│    for each registered test case        │
└─────────────┬───────────────────────────┘
              │
              v
┌─────────────────────────────────────────┐
│  Module__UnitTests("TestCase1")         │
│  Module__UnitTests("TestCase2")         │
│  Module__UnitTests("TestCase3")         │
│  - Individual test assertions           │
└─────────────┬───────────────────────────┘
              │
              v
┌─────────────────────────────────────────┐
│  Module__UnitTests("TearDown")          │
│  - Cleanup test data                    │
└─────────────────────────────────────────┘
```

### Test Runner Method

`UnitTest_RunTest("TestCaseName")` executes individual test cases:

```4d
: ($action = "RunTests")
    UnitTest_RunTest("IdentifyDates - Weekly")
    UnitTest_RunTest("IdentifyDates - 1st Week of Month")
    UnitTest_RunTest("IdentifyDates - 2 x Monthly")
    UnitTest_RunTest("Calculate Units")
    UnitTest_RunTest("Calculate Billable Amount")
```

Each `UnitTest_RunTest()` call invokes the test method with the corresponding action name.

---

## Assertion Library

The framework provides a comprehensive assertion library for type-specific validations.

### Numeric Assertions

**Integer Comparison:**
```4d
UnitTest_AssertEqualLongint(expected; actual; "description")
```
Example:
```4d
UnitTest_AssertEqualLongint(1; Hippa_Unit_Calculation(15); "15 minutes = 1 unit")
UnitTest_AssertEqualLongint(0; Hippa_Unit_Calculation(14); "14 minutes = 0 units")
```

**Real Number Comparison:**
```4d
UnitTest_AssertEqualReal(expected; actual)
```
Example:
```4d
UnitTest_AssertEqualReal(47.50; Treatments_Calc_BilledAmount(1; 47.50; 1.00))
```

### Text Assertions

**Case-Insensitive:**
```4d
UnitTest_AssertEqualText(expected; actual)
```

**Case-Sensitive:**
```4d
UnitTest_AssertEqualTextAndCase(expected; actual)
```

### Date & Time Assertions

**Date Comparison:**
```4d
UnitTest_AssertEqualDate(expected; actual)
```
Example:
```4d
UnitTest_AssertEqualDate(!2017-01-02!; $dateArr{1})
```

**Time Comparison:**
```4d
UnitTest_AssertEqualTime(expected; actual)
```

### Collection/Array Assertions

**Array Size:**
```4d
UnitTest_AssertArraySize(expectedSize; arrayPointer)
```
Example:
```4d
ARRAY DATE($dateArr; 0)
TreatmentRecords_IdentifyDates(->$dateArr; "Monthly"; $dayObjectStr; !2017-01-01!; !2017-01-31!)
UnitTest_AssertArraySize(1; ->$dateArr; "Expect 1 date for monthly frequency")
```

**Record Count:**
```4d
UnitTest_AssertRecordCount(expected; tablePointer)
```

### Boolean Assertions

**Assert True:**
```4d
UnitTest_AssertTrue(condition; "message")
UnitTest_Assert(condition; "message")  // Alias
```

**Assert False:**
```4d
UnitTest_AssertFalse(condition; "message")
```

### Pointer Assertions

**Equal Pointers:**
```4d
UnitTest_AssertEqualPointer(expected; actual)
```

**Nil/Not Nil:**
```4d
UnitTest_AssertNil(pointer)
UnitTest_AssertNotNil(pointer)
```

### File System Assertions

**File Exists:**
```4d
UnitTest_AssertFileExists(filePath)
```

**Folder Exists:**
```4d
UnitTest_AssertFolderExists(folderPath)
```

---

## Lifecycle Hooks

### Setup

Executed **once** before running all test cases in a suite:

```4d
: ($action = "Setup")
    // Initialize test data
    CREATE RECORD([TestTable])
    [TestTable]Field1:="Test Value"
    SAVE RECORD([TestTable])
```

Use for:
- Database record creation
- Loading test fixtures
- Setting global test variables
- Opening connections

### TearDown

Executed **once** after all test cases complete:

```4d
: ($action = "TearDown")
    // Cleanup test data
    DELETE SELECTION([TestTable])
```

Use for:
- Deleting test records
- Closing connections
- Releasing resources
- Resetting application state

### NOP Pattern

If no setup or teardown is required, use the "No Operation" pattern:

```4d
: ($action = "Setup")
    // NOP

: ($action = "TearDown")
    // NOP
```

---

## Model Examples

### Simple Focused Test: HIPPA__UnitTests

Tests a single method (`Hippa_Unit_Calculation`) with comprehensive boundary cases:

```4d
//%attributes = {"invisible":true,"shared":true,"preemptive":"incapable"}
// HIPPA__UnitTests
// $1 = Action

If (Count parameters = 0)
    UnitTest_Setup_EEM
Else
    C_TEXT($1; $action)
    $action:=$1
    
    Case of
        : ($action = "RunTests")
            UnitTest_RunTest("Hippa_Unit_Calculation")
            
        : ($action = "Setup")
            // NOP
            
        : ($action = "TearDown")
            // NOP
            
        : ($action = "Hippa_Unit_Calculation")
            // Boundary testing: negative values
            UnitTest_AssertEqualLongint(0; Hippa_Unit_Calculation(-1); "unit -1 min")
            UnitTest_AssertEqualLongint(0; Hippa_Unit_Calculation(0); "unit 0 min")
            
            // Edge cases around 15-minute threshold
            UnitTest_AssertEqualLongint(0; Hippa_Unit_Calculation(6); "unit 6 min")
            UnitTest_AssertEqualLongint(0; Hippa_Unit_Calculation(7); "unit 7 min")
            UnitTest_AssertEqualLongint(1; Hippa_Unit_Calculation(8); "unit 8 min")
            
            // Threshold boundary (14 vs 15 minutes)
            UnitTest_AssertEqualLongint(0; Hippa_Unit_Calculation(14); "unit 14 min")
            UnitTest_AssertEqualLongint(1; Hippa_Unit_Calculation(15); "unit 15 min")
            UnitTest_AssertEqualLongint(1; Hippa_Unit_Calculation(16); "unit 16 min")
            
            // Next threshold (22 vs 23 minutes)
            UnitTest_AssertEqualLongint(1; Hippa_Unit_Calculation(22); "unit 22 min")
            UnitTest_AssertEqualLongint(2; Hippa_Unit_Calculation(23); "unit 23 min")
            
            // 60-minute unit threshold
            UnitTest_AssertEqualLongint(0; Hippa_Unit_Calculation(14; 60); "unit 14 min (60 min threshold)")
            UnitTest_AssertEqualLongint(1; Hippa_Unit_Calculation(60; 60); "unit 60 min (60 min threshold)")
    End case
End if
```

**Testing Strategy:**
- Exhaustive boundary testing around thresholds
- Negative value handling
- Multiple threshold configurations
- Clear descriptive assertion messages

### Complex Multi-Method Test: Treatments__UnitTests

Tests multiple calculation and scheduling methods with varied data types:

```4d
//%attributes = {"invisible":true,"shared":true}
// Treatments__UnitTests
// $1 = Action

#DECLARE($action : Text)

If (Count parameters = 0)
    UnitTest_Setup_EEM
    return
End if

var $i : Integer
var $dayObject : Object
var $nonSchedulableDateList : Collection
ARRAY DATE($dateArr; 0)

Case of
    : ($action = "RunTests")
        UnitTest_RunTest("IdentifyDates - Weekly")
        UnitTest_RunTest("IdentifyDates - 1st Week of Month")
        UnitTest_RunTest("IdentifyDates - 2 x Monthly")
        UnitTest_RunTest("IdentifyDates - 3 x Monthly")
        UnitTest_RunTest("IdentifyDates - 4 x Monthly")
        UnitTest_RunTest("IdentifyDates - Last Week of Month")
        UnitTest_RunTest("IdentifyDates - Custom")
        UnitTest_RunTest("Calculate Units")
        UnitTest_RunTest("Calculate Billable Amount")
        UnitTest_RunTest("Calculate Amount Expected")
        
    : ($action = "Setup")
        // NOP
        
    : ($action = "TearDown")
        // NOP
        
    : ($action = "Calculate Units")
        // Loop-based testing for 1-100 minute durations
        For ($i; 1; 7)
            UnitTest_AssertEqualLongint(0; Treatments_Calc_Units($i; "8-15 minutes"))
        End for
        For ($i; 8; 22)
            UnitTest_AssertEqualLongint(1; Treatments_Calc_Units($i; "8-15 minutes"))
        End for
        For ($i; 23; 37)
            UnitTest_AssertEqualLongint(2; Treatments_Calc_Units($i; "8-15 minutes"))
        End for
        
        // Test multiple threshold configurations
        UnitTest_AssertEqualLongint(0; Treatments_Calc_Units(14; "15 minutes"))
        UnitTest_AssertEqualLongint(1; Treatments_Calc_Units(15; "15 minutes"))
        UnitTest_AssertEqualLongint(0; Treatments_Calc_Units(29; "30 minutes"))
        UnitTest_AssertEqualLongint(1; Treatments_Calc_Units(30; "30 minutes"))
        
    : ($action = "Calculate Billable Amount")
        // Real number calculations
        UnitTest_AssertEqualReal(47.50; Treatments_Calc_BilledAmount(1; 47.50; 1.00))
        UnitTest_AssertEqualReal(95.00; Treatments_Calc_BilledAmount(2; 47.50; 1.00))
        UnitTest_AssertEqualReal(23.75; Treatments_Calc_BilledAmount(1; 47.50; 0.50))
        
    : ($action = "Calculate Amount Expected")
        // Federal percentage calculations
        UnitTest_AssertEqualReal(28.50; Treatments_Calc_AmountExpected(47.50; 1; 0.60))
        UnitTest_AssertEqualReal(14.25; Treatments_Calc_AmountExpected(47.50; 2; 0.60))
        
    : ($action = "IdentifyDates - Weekly")
        $dayObject:={days_of_week: "0101000"}  // Monday scheduling
        TreatmentRecords_IdentifyDates(->$dateArr; "Weekly"; $dayObject; !2017-01-01!; !2017-01-31!)
        UnitTest_AssertArraySize(5; ->$dateArr)
        UnitTest_AssertEqualDate(!2017-01-02!; $dateArr{1})
        UnitTest_AssertEqualDate(!2017-01-09!; $dateArr{2})
        
    : ($action = "IdentifyDates - 1st Week of Month")
        $dayObject:={days_of_week: "0101000"}
        TreatmentRecords_IdentifyDates(->$dateArr; "Monthly"; $dayObject; !2017-01-01!; !2017-01-31!)
        UnitTest_AssertArraySize(1; ->$dateArr)
        UnitTest_AssertEqualDate(!2017-01-02!; $dateArr{1})
        
        // Test start date after 1st of month
        TreatmentRecords_IdentifyDates(->$dateArr; "Monthly"; $dayObject; !2016-01-05!; !2016-02-29!)
        UnitTest_AssertArraySize(1; ->$dateArr; "Expect 1 date when start is after 1st day of month")
        
    : ($action = "IdentifyDates - 2 x Monthly")
        $dayObject:={days_of_week: "0101000"}
        TreatmentRecords_IdentifyDates(->$dateArr; "2 x Monthly"; $dayObject; !2017-01-01!; !2017-01-31!)
        UnitTest_AssertArraySize(2; ->$dateArr)
End case
```

**Testing Strategy:**
- Loop-based testing for ranges of values
- Object-based test configuration (`$dayObject`)
- Array pointer assertions
- Date range testing with different patterns
- Multiple method testing in one suite

---

## Component Testing

### IH_WebShell Component Tests

The IH_WebShell component exports multiple unit test methods:

- `Audit__UnitTests` - Audit trail testing
- `Cookie__UnitTests` - Cookie management testing
- `HTML__UnitTests` - HTML generation testing
- `OBJ__UnitTests` - Object manipulation testing
- `Router__UnitTests` - Web routing testing
- `Sessions__UnitTests` - Session management testing
- `Util__UnitTests` - Utility function testing
- `WebForm__UnitTests` - Web form generation testing

### Component Integration

Component tests are registered via `UnitTest_Setup_IHWebShell`:

```4d
// In UnitTest_Setup_EEM.4dm
UnitTest_AddTestCase("Treatments__UnitTests")
UnitTest_AddTestCase("HIPPA__UnitTests")

// Add component tests (which chains to IH_Core tests)
UnitTest_Setup_IHWebShell
```

**Component Test Chain:**
- `UnitTest_Setup_EEM` (project level)
- → `UnitTest_Setup_IHWebShell` (IH_WebShell component)
- → `UnitTest_Setup_IHCore` (IH_Core component)

This creates a hierarchical test suite spanning project and all component layers.

---

## Test Organization Best Practices

### 1. Naming Conventions

**Test Method Names:**
- Use `<Module>__UnitTests` pattern
- Module should match the code being tested
- Examples: `HIPPA__UnitTests`, `Treatments__UnitTests`

**Test Case Names:**
- Use descriptive, hyphenated names
- Include what's being tested and the scenario
- Examples: `"IdentifyDates - Weekly"`, `"Calculate Units"`, `"Boundary - Zero Values"`

### 2. Test Case Organization

**Group by functionality:**
```4d
: ($action = "RunTests")
    // Calculation tests
    UnitTest_RunTest("Calculate Units")
    UnitTest_RunTest("Calculate Billable Amount")
    UnitTest_RunTest("Calculate Amount Expected")
    
    // Date identification tests
    UnitTest_RunTest("IdentifyDates - Weekly")
    UnitTest_RunTest("IdentifyDates - Monthly")
    UnitTest_RunTest("IdentifyDates - 2 x Monthly")
```

### 3. Assertion Messages

**Always include descriptive messages:**
```4d
// Good: Clear context
UnitTest_AssertEqualLongint(1; Hippa_Unit_Calculation(15); "15 minutes = 1 unit")

// Good: Explains edge case
UnitTest_AssertArraySize(1; ->$dateArr; "Expect 1 date when start is after 1st day of month")

// Acceptable: Implicit context
UnitTest_AssertEqualReal(47.50; Treatments_Calc_BilledAmount(1; 47.50; 1.00))
```

### 4. Boundary Testing Strategy

Test edge cases systematically:

```4d
// Test boundary thresholds
UnitTest_AssertEqualLongint(0; Method(threshold - 1))
UnitTest_AssertEqualLongint(1; Method(threshold))
UnitTest_AssertEqualLongint(1; Method(threshold + 1))

// Test invalid inputs
UnitTest_AssertEqualLongint(0; Method(-1))
UnitTest_AssertEqualLongint(0; Method(0))

// Test maximum values
UnitTest_AssertEqualLongint(expected; Method(max_value))
```

### 5. Loop-Based Testing

For ranges of similar tests, use loops:

```4d
// Test range 1-7 expecting 0 units
For ($i; 1; 7)
    UnitTest_AssertEqualLongint(0; Treatments_Calc_Units($i; "8-15 minutes"))
End for

// Test range 8-22 expecting 1 unit
For ($i; 8; 22)
    UnitTest_AssertEqualLongint(1; Treatments_Calc_Units($i; "8-15 minutes"))
End for
```

### 6. Test Data Management

Use local variables for test fixtures:

```4d
var $i : Integer
var $dayObject : Object
var $nonSchedulableDateList : Collection
ARRAY DATE($dateArr; 0)

// Configure test data
$dayObject:={days_of_week: "0101000"}
$nonSchedulableDateList:=New collection(!2017-01-01!; !2017-01-15!)
```

---

## Running Tests

### From 4D Method Editor

1. Open any `__UnitTests` method
2. Execute the method (Ctrl/Cmd + R)
3. Test dialog appears with all registered test suites
4. Select tests to run and click "Run Tests" button

### Programmatic Execution

Execute specific test suites:

```4d
// Run single test suite
Treatments__UnitTests("RunTests")

// Run specific test case
Treatments__UnitTests("Calculate Units")

// Run lifecycle hooks
Treatments__UnitTests("Setup")
Treatments__UnitTests("TearDown")
```

### Test Suite Runner

Launch full test runner dialog:

```4d
UnitTest_Setup_EEM  // Shows dialog with all registered tests
```

---

## Test Dialog Form

The test runner uses `UnitTest_Dialog` form from the Code Analysis component:

**Features:**
- Displays all registered test suites
- Allows selective test execution
- Shows pass/fail status
- Reports assertion failures with line numbers
- Provides test execution timing

**Form Location:**
- `Components/Code Analysis.4dbase/Project/Sources/Forms/UnitTest_Dialog/`

---

## Framework Methods Reference

### Registration & Initialization

| Method | Purpose |
|--------|---------|
| `UnitTest_Init("all_soft")` | Initialize test framework |
| `UnitTest_AddTestCase("MethodName")` | Register test method |
| `UnitTest_ShowDialog` | Display test runner |

### Test Execution

| Method | Purpose |
|--------|---------|
| `UnitTest_RunTest("TestCaseName")` | Execute individual test case |
| `UnitTest_Setup_EEM` | Project-level test suite launcher |
| `UnitTest_Setup_IHWebShell` | Component-level test suite registration |
| `UnitTest_Setup_IHCore` | Core component test suite registration |

### Assertions

| Method | Purpose |
|--------|---------|
| `UnitTest_AssertEqualLongint(exp; act; msg)` | Assert integers equal |
| `UnitTest_AssertEqualReal(exp; act)` | Assert reals equal |
| `UnitTest_AssertEqualText(exp; act)` | Assert text equal (case-insensitive) |
| `UnitTest_AssertEqualTextAndCase(exp; act)` | Assert text equal (case-sensitive) |
| `UnitTest_AssertEqualDate(exp; act)` | Assert dates equal |
| `UnitTest_AssertEqualTime(exp; act)` | Assert times equal |
| `UnitTest_AssertEqualPointer(exp; act)` | Assert pointers equal |
| `UnitTest_AssertArraySize(size; ptr)` | Assert array size |
| `UnitTest_AssertRecordCount(exp; tblPtr)` | Assert record count |
| `UnitTest_Assert(condition; msg)` | Assert boolean true |
| `UnitTest_AssertTrue(condition; msg)` | Assert boolean true |
| `UnitTest_AssertFalse(condition; msg)` | Assert boolean false |
| `UnitTest_AssertNil(ptr)` | Assert pointer is nil |
| `UnitTest_AssertNotNil(ptr)` | Assert pointer not nil |
| `UnitTest_AssertFileExists(path)` | Assert file exists |
| `UnitTest_AssertFolderExists(path)` | Assert folder exists |

---

## Adding New Tests

### Step 1: Create Test Method

Create new method following naming convention:

```4d
//%attributes = {"invisible":true,"shared":true}
// MyModule__UnitTests
// $1 = Action

#DECLARE($action : Text)

If (Count parameters = 0)
    UnitTest_Setup_EEM
    return
End if

Case of
    : ($action = "RunTests")
        UnitTest_RunTest("Test Case 1")
        
    : ($action = "Setup")
        // NOP
        
    : ($action = "TearDown")
        // NOP
        
    : ($action = "Test Case 1")
        // Implement assertions
        UnitTest_Assert(True; "Test placeholder")
End case
```

### Step 2: Register Test Method

Add to [UnitTest_Setup_EEM.4dm](../../Project/Sources/Methods/UnitTest_Setup_EEM.4dm):

```4d
UnitTest_Init("all_soft")

UnitTest_AddTestCase("Treatments__UnitTests")
UnitTest_AddTestCase("HIPPA__UnitTests")
UnitTest_AddTestCase("MyModule__UnitTests")  // Add new test

UnitTest_Setup_IHWebShell
UnitTest_ShowDialog
```

### Step 3: Run Tests

Execute `UnitTest_Setup_EEM` to verify registration and run new tests.

---

## Troubleshooting

### Test Not Appearing in Dialog

**Problem:** Test method registered but not showing in dialog

**Solutions:**
1. Verify method name uses `__UnitTests` suffix
2. Check `UnitTest_AddTestCase()` call in `UnitTest_Setup_EEM`
3. Ensure method attributes include `shared:true`
4. Restart test dialog: re-execute `UnitTest_Setup_EEM`

### Assertion Failures Not Descriptive

**Problem:** Assertion fails with no context

**Solution:** Always include description parameter:
```4d
// Before
UnitTest_AssertEqualLongint(1; result)

// After
UnitTest_AssertEqualLongint(1; result; "Calculate Units should return 1 for 15 minutes")
```

### Test Hangs or Times Out

**Problem:** Test execution stops responding

**Solutions:**
1. Check for infinite loops in test code
2. Verify `Setup` and `TearDown` don't block
3. Ensure tested method doesn't require user interaction
4. Add debug logging to identify blocking operation

### Component Tests Not Registered

**Problem:** IH_WebShell tests not appearing

**Solution:** Verify `UnitTest_Setup_IHWebShell` is called:
```4d
UnitTest_Setup_IHWebShell  // Must be after project tests
```

---

## Related Documentation

- [4D Coding Style Guide](4d-coding-style.md) - General coding conventions
- [Incoming Web Request Architecture](incoming-web-request-arch.md) - Web request handling
- [Outbox Reporting](outbox-reporting.md) - Reporting mechanisms

---

## Summary

The unit testing architecture provides:

✅ **xUnit-style framework** adapted for 4D environment  
✅ **Action-based dispatcher** for flexible test organization  
✅ **Comprehensive assertion library** with 15+ type-specific methods  
✅ **Self-executing test methods** for easy test running  
✅ **Lifecycle hooks** (Setup/TearDown) for test fixtures  
✅ **Component integration** for testing across project boundaries  
✅ **Interactive test dialog** for selective test execution  
✅ **Clear testing patterns** demonstrated in HIPPA and Treatments examples  

The framework enables systematic testing of business logic, calculations, date scheduling, and data transformations with clear, maintainable test code.
