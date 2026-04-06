//%attributes = {"invisible":true,"preemptive":"incapable"}
// Init__UnitTests ($action)
// Unit tests for Init_ThreadSafe and Init_GlobalTracking

#DECLARE($action : Text)

C_COLLECTION:C1488(__STACK)
C_OBJECT:C1216(__PerfObj; __PerfFlameObj)
C_LONGINT:C283(__incrementLevel)

Case of 
	: ($action="RunTests")
		UnitTest_RunTest("Init_ThreadSafe_CreatesStack")
		UnitTest_RunTest("Init_ThreadSafe_InitializesIncrementLevel")
		UnitTest_RunTest("Init_ThreadSafe_CreatesPerfObjects")
		UnitTest_RunTest("Init_ThreadSafe_ForcedReinitResetsState")
		UnitTest_RunTest("Init_ThreadSafe_IdempotentWithoutForce")
		UnitTest_RunTest("Init_GlobalTracking_CreatesObjects")
		UnitTest_RunTest("Init_GlobalTracking_ForcedReinitClearsExisting")
		UnitTest_RunTest("Init_GlobalTracking_IdempotentWithoutForce")
		
	: ($action="Setup")
		// Force a clean state before each test
		Init_ThreadSafe(True:C214)
		Init_GlobalTracking(True:C214)
		
	: ($action="TearDown")
		// Leave a clean state after each test
		Init_ThreadSafe(True:C214)
		Init_GlobalTracking(True:C214)
		
	: ($action="Init_ThreadSafe_CreatesStack")
		Init_ThreadSafe(True:C214)
		UnitTest_Assert(__STACK#Null:C1517; "Init_ThreadSafe should create __STACK as a non-null collection")
		UnitTest_Assert(__STACK.length=0; "__STACK should be empty after initialization, length: "+String:C10(__STACK.length))
		
	: ($action="Init_ThreadSafe_InitializesIncrementLevel")
		Init_ThreadSafe(True:C214)
		UnitTest_Assert(__incrementLevel=0; "__incrementLevel should be 0 after initialization, got: "+String:C10(__incrementLevel))
		
	: ($action="Init_ThreadSafe_CreatesPerfObjects")
		Init_ThreadSafe(True:C214)
		UnitTest_Assert(__PerfObj#Null:C1517; "__PerfObj should be a non-null object after initialization")
		UnitTest_Assert(__PerfFlameObj#Null:C1517; "__PerfFlameObj should be a non-null object after initialization")
		UnitTest_Assert(__PerfObj._numItems=0; "__PerfObj._numItems should be 0 after initialization, got: "+String:C10(__PerfObj._numItems))
		UnitTest_Assert(__PerfFlameObj._numItems=0; "__PerfFlameObj._numItems should be 0, got: "+String:C10(__PerfFlameObj._numItems))
		
	: ($action="Init_ThreadSafe_ForcedReinitResetsState")
		// Push something onto the stack so we can verify it gets cleared
		Init_ThreadSafe(True:C214)
		__STACK.push(New object:C1471("tag"; "sentinel"))
		__incrementLevel:=3
		// Now force reinit
		Init_ThreadSafe(True:C214)
		UnitTest_Assert(__STACK.length=0; "Forced reinit should clear __STACK, length: "+String:C10(__STACK.length))
		UnitTest_Assert(__incrementLevel=0; "Forced reinit should reset __incrementLevel, got: "+String:C10(__incrementLevel))
		
	: ($action="Init_ThreadSafe_IdempotentWithoutForce")
		// Without forcing, calling Init_ThreadSafe again should NOT clear state put there after first init
		Init_ThreadSafe(True:C214)
		__STACK.push(New object:C1471("tag"; "preserved"))
		Init_ThreadSafe  // no force - should be a no-op
		UnitTest_Assert(__STACK.length=1; "Non-forced Init_ThreadSafe should not clear existing __STACK, length: "+String:C10(__STACK.length))
		
	: ($action="Init_GlobalTracking_CreatesObjects")
		Init_GlobalTracking(True:C214)
		
		C_OBJECT:C1216(__Global_PerfObj; __Global_PerfFlameObj)
		UnitTest_Assert(__Global_PerfObj#Null:C1517; "__Global_PerfObj should be non-null after Init_GlobalTracking")
		UnitTest_Assert(__Global_PerfFlameObj#Null:C1517; "__Global_PerfFlameObj should be non-null after Init_GlobalTracking")
		UnitTest_Assert(__Global_PerfObj._numItems=0; "__Global_PerfObj._numItems should be 0, got: "+String:C10(__Global_PerfObj._numItems))
		UnitTest_Assert(__Global_PerfFlameObj._numItems=0; "__Global_PerfFlameObj._numItems should be 0, got: "+String:C10(__Global_PerfFlameObj._numItems))
		
	: ($action="Init_GlobalTracking_ForcedReinitClearsExisting")
		C_OBJECT:C1216(__Global_PerfObj; __Global_PerfFlameObj)
		Init_GlobalTracking(True:C214)
		__Global_PerfObj._numItems:=5  // simulate accumulated data
		Init_GlobalTracking(True:C214)  // forced reinit should reset
		UnitTest_Assert(__Global_PerfObj._numItems=0; \
			"Forced Init_GlobalTracking should reset _numItems to 0, got: "+String:C10(__Global_PerfObj._numItems))
		
	: ($action="Init_GlobalTracking_IdempotentWithoutForce")
		C_OBJECT:C1216(__Global_PerfObj; __Global_PerfFlameObj)
		Init_GlobalTracking(True:C214)
		__Global_PerfObj._numItems:=7  // simulate accumulated data
		Init_GlobalTracking  // no force - should not reset
		UnitTest_Assert(__Global_PerfObj._numItems=7; \
			"Non-forced Init_GlobalTracking should preserve existing _numItems, got: "+String:C10(__Global_PerfObj._numItems))
		
End case 
