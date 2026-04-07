//%attributes = {"invisible":true,"preemptive":"incapable"}
// Performance__UnitTests ($action)
// Unit tests for Performance_UpdateTrackingObj

#DECLARE($action : Text)

Case of 
		
	: ($action="")
		UnitTest_Setup_IHProfiler()
		
	: ($action="RunTests")
		UnitTest_RunTest("Performance_UpdateTrackingObj_CreatesFirstEntry")
		UnitTest_RunTest("Performance_UpdateTrackingObj_UpdatesSecondCall")
		UnitTest_RunTest("Performance_UpdateTrackingObj_UpdatesMinWhenLower")
		UnitTest_RunTest("Performance_UpdateTrackingObj_UpdatesMaxWhenHigher")
		UnitTest_RunTest("Performance_UpdateTrackingObj_AccumulatesTotal")
		UnitTest_RunTest("Performance_UpdateTrackingObj_IncrementsNumItems")
		UnitTest_RunTest("Performance_UpdateTrackingObj_MultipleKeys")
		UnitTest_RunTest("Performance_UpdateTrackingObj_SpacesReplacedByUnderscores")
		UnitTest_RunTest("Performance_UpdateTrackingObj_NumItemsKeyCollision")
		
		
	: ($action="Performance_UpdateTrackingObj_CreatesFirstEntry")
		var $obj : Object
		$obj:=New object:C1471("_numItems"; 0)
		Performance_UpdateTrackingObj($obj; "testMethod"; 100)
		
		UnitTest_Assert($obj["testMethod"]#Null:C1517; "First call should create an entry for 'testMethod'")
		UnitTest_Assert($obj["testMethod"].min=100; "min should be 100 on first call, got: "+String:C10($obj["testMethod"].min))
		UnitTest_Assert($obj["testMethod"].max=100; "max should be 100 on first call, got: "+String:C10($obj["testMethod"].max))
		UnitTest_Assert($obj["testMethod"].total=100; "total should be 100 on first call, got: "+String:C10($obj["testMethod"].total))
		UnitTest_Assert($obj["testMethod"].callCount=1; "callCount should be 1 on first call, got: "+String:C10($obj["testMethod"].callCount))
		
		
	: ($action="Performance_UpdateTrackingObj_UpdatesSecondCall")
		var $obj : Object
		$obj:=New object:C1471("_numItems"; 0)
		Performance_UpdateTrackingObj($obj; "testMethod"; 100)
		Performance_UpdateTrackingObj($obj; "testMethod"; 200)
		
		UnitTest_Assert($obj["testMethod"].callCount=2; "callCount should be 2 after two calls, got: "+String:C10($obj["testMethod"].callCount))
		UnitTest_Assert($obj["testMethod"].total=300; "total should be 300 (100+200), got: "+String:C10($obj["testMethod"].total))
		
		
	: ($action="Performance_UpdateTrackingObj_UpdatesMinWhenLower")
		var $obj : Object
		$obj:=New object:C1471("_numItems"; 0)
		Performance_UpdateTrackingObj($obj; "m"; 100)
		Performance_UpdateTrackingObj($obj; "m"; 50)  // lower value should update min
		
		UnitTest_Assert($obj["m"].min=50; "min should be updated to 50 when a lower value is recorded, got: "+String:C10($obj["m"].min))
		UnitTest_Assert($obj["m"].max=100; "max should remain 100, got: "+String:C10($obj["m"].max))
		
		
	: ($action="Performance_UpdateTrackingObj_UpdatesMaxWhenHigher")
		var $obj : Object
		$obj:=New object:C1471("_numItems"; 0)
		Performance_UpdateTrackingObj($obj; "m"; 100)
		Performance_UpdateTrackingObj($obj; "m"; 250)  // higher value should update max
		
		UnitTest_Assert($obj["m"].max=250; "max should be updated to 250 when a higher value is recorded, got: "+String:C10($obj["m"].max))
		UnitTest_Assert($obj["m"].min=100; "min should remain 100, got: "+String:C10($obj["m"].min))
		
		
	: ($action="Performance_UpdateTrackingObj_AccumulatesTotal")
		var $obj : Object
		$obj:=New object:C1471("_numItems"; 0)
		Performance_UpdateTrackingObj($obj; "m"; 10)
		Performance_UpdateTrackingObj($obj; "m"; 20)
		Performance_UpdateTrackingObj($obj; "m"; 30)
		
		UnitTest_Assert($obj["m"].total=60; "total should be 60 (10+20+30), got: "+String:C10($obj["m"].total))
		UnitTest_Assert($obj["m"].callCount=3; "callCount should be 3, got: "+String:C10($obj["m"].callCount))
		
		
	: ($action="Performance_UpdateTrackingObj_IncrementsNumItems")
		var $obj : Object
		$obj:=New object:C1471("_numItems"; 0)
		Performance_UpdateTrackingObj($obj; "method1"; 10)
		Performance_UpdateTrackingObj($obj; "method2"; 20)
		Performance_UpdateTrackingObj($obj; "method2"; 30)  // second call to method2, no new key
		
		UnitTest_Assert($obj._numItems=2; "_numItems should be 2 for two distinct methods, got: "+String:C10($obj._numItems))
		
		
	: ($action="Performance_UpdateTrackingObj_MultipleKeys")
		var $obj : Object
		$obj:=New object:C1471("_numItems"; 0)
		Performance_UpdateTrackingObj($obj; "alpha"; 10)
		Performance_UpdateTrackingObj($obj; "beta"; 20)
		
		UnitTest_Assert($obj["alpha"]#Null:C1517; "'alpha' entry should exist")
		UnitTest_Assert($obj["beta"]#Null:C1517; "'beta' entry should exist")
		UnitTest_Assert($obj["alpha"].total=10; "'alpha' total should be 10, got: "+String:C10($obj["alpha"].total))
		UnitTest_Assert($obj["beta"].total=20; "'beta' total should be 20, got: "+String:C10($obj["beta"].total))
		
		
	: ($action="Performance_UpdateTrackingObj_SpacesReplacedByUnderscores")
		// Method names with spaces should have spaces replaced by underscores
		var $obj : Object
		$obj:=New object:C1471("_numItems"; 0)
		Performance_UpdateTrackingObj($obj; "my method"; 50)
		
		UnitTest_Assert($obj["my_method"]#Null:C1517; "Spaces in method name should be replaced with underscores")
		UnitTest_Assert($obj["my method"]=Null:C1517; "Original name with space should not exist as a key")
		
		
	: ($action="Performance_UpdateTrackingObj_NumItemsKeyCollision")
		// Tracking an item named "_numItems" should not corrupt the counter
		var $obj : Object
		$obj:=New object:C1471("_numItems"; 0)
		Performance_UpdateTrackingObj($obj; "_numItems"; 10)
		
		// The method appends a space to avoid collision: key becomes "_numItems "
		UnitTest_Assert($obj._numItems=1; "_numItems counter should be 1, not corrupted by collision handling, got: "+String:C10($obj._numItems))
		
End case 
