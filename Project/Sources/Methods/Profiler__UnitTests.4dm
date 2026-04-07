//%attributes = {"invisible":true,"preemptive":"incapable"}
// Profiler__UnitTests ($action)
// Unit tests for Profiler_START, Profiler_STOP, Profiler_CallStack_GetCurrent,
// Profiler_CallStack_GetPrevious, and Profiler_ClearProcessStats

#DECLARE($action : Text)

Case of 
	: ($action="")
		UnitTest_Setup_IHProfiler()
		
		
	: ($action="RunTests")
		UnitTest_RunTest("Profiler_START_SetsCurrentMethod")
		UnitTest_RunTest("Profiler_START_PushesNestedMethods")
		UnitTest_RunTest("Profiler_STOP_RemovesCurrentMethod")
		UnitTest_RunTest("Profiler_STOP_BalancedCallLeavesEmptyStack")
		UnitTest_RunTest("Profiler_CallStack_GetCurrent_ReturnsTopTag")
		UnitTest_RunTest("Profiler_CallStack_GetCurrent_EmptyStackFallback")
		UnitTest_RunTest("Profiler_CallStack_GetPrevious_ReturnsPreviousTag")
		UnitTest_RunTest("Profiler_CallStack_GetPrevious_EmptyWhenOneItem")
		UnitTest_RunTest("Profiler_ClearProcessStats_ResetsState")
		UnitTest_RunTest("Profiler_START_SpacesReplacedByUnderscores")
		UnitTest_RunTest("Profiler_multiple_levels")
		
		
	: ($action="Setup")
		// Ensure a clean profiler state before each test
		Profiler_ClearProcessStats
		
		
	: ($action="TearDown")
		// Clean up any uncommitted profiler entries after each test
		Profiler_ClearProcessStats
		
		
	: ($action="Profiler_START_SetsCurrentMethod")
		Profiler_START("UnitTest_Method")
		var $current : Text
		$current:=Profiler_CallStack_GetCurrent
		UnitTest_Assert($current="UnitTest_Method"; \
			"GetCurrent should return 'UnitTest_Method' after START, got: "+$current)
		Profiler_STOP("UnitTest_Method")
		
		
	: ($action="Profiler_START_PushesNestedMethods")
		Profiler_START("OuterMethod")
		Profiler_START("InnerMethod")
		var $current : Text
		$current:=Profiler_CallStack_GetCurrent
		UnitTest_Assert($current="InnerMethod"; \
			"GetCurrent on nested START should return innermost method, got: "+$current)
		Profiler_STOP("InnerMethod")
		Profiler_STOP("OuterMethod")
		
		
	: ($action="Profiler_STOP_RemovesCurrentMethod")
		Profiler_START("MethodA")
		Profiler_START("MethodB")
		Profiler_STOP("MethodB")
		var $current : Text
		$current:=Profiler_CallStack_GetCurrent
		UnitTest_Assert($current="MethodA"; \
			"After stopping MethodB, GetCurrent should return MethodA, got: "+$current)
		Profiler_STOP("MethodA")
		
		
	: ($action="Profiler_STOP_BalancedCallLeavesEmptyStack")
		Profiler_START("SingleMethod")
		Profiler_STOP("SingleMethod")
		var $current : Text
		$current:=Profiler_CallStack_GetCurrent
		// Empty stack falls back to "unknown method"
		UnitTest_Assert($current="unknown method"; \
			"Empty stack after balanced START/STOP, GetCurrent should return 'unknown method', got: "+$current)
		
		
	: ($action="Profiler_CallStack_GetCurrent_ReturnsTopTag")
		Profiler_START("TagAlpha")
		var $result : Text
		$result:=Profiler_CallStack_GetCurrent
		UnitTest_Assert($result="TagAlpha"; \
			"GetCurrent should return 'TagAlpha', got: "+$result)
		Profiler_STOP("TagAlpha")
		
		
	: ($action="Profiler_CallStack_GetCurrent_EmptyStackFallback")
		// After clearing, stack is empty -> returns "unknown method"
		var $result : Text
		$result:=Profiler_CallStack_GetCurrent
		UnitTest_Assert($result="unknown method"; \
			"Empty stack should return 'unknown method', got: "+$result)
		
		
	: ($action="Profiler_CallStack_GetPrevious_ReturnsPreviousTag")
		Profiler_START("FirstMethod")
		Profiler_START("SecondMethod")
		var $prev : Text
		$prev:=Profiler_CallStack_GetPrevious
		UnitTest_Assert($prev="FirstMethod"; \
			"GetPrevious should return 'FirstMethod' when two methods on stack, got: "+$prev)
		Profiler_STOP("SecondMethod")
		Profiler_STOP("FirstMethod")
		
		
	: ($action="Profiler_CallStack_GetPrevious_EmptyWhenOneItem")
		Profiler_START("OnlyMethod")
		var $prev : Text
		$prev:=Profiler_CallStack_GetPrevious
		UnitTest_Assert($prev=""; \
			"GetPrevious should return '' when only one method on stack, got: "+$prev)
		Profiler_STOP("OnlyMethod")
		
		
	: ($action="Profiler_ClearProcessStats_ResetsState")
		Profiler_START("MethodToBeCleared")
		Profiler_ClearProcessStats
		// After forced clear, stack is empty -> GetCurrent returns "unknown method"
		var $current : Text
		$current:=Profiler_CallStack_GetCurrent
		UnitTest_Assert($current="unknown method"; \
			"After ClearProcessStats, stack should be empty, GetCurrent='unknown method', got: "+$current)
		
		
	: ($action="Profiler_START_SpacesReplacedByUnderscores")
		// Spaces in profiler tags should be replaced with underscores
		Profiler_START("my method")
		var $current : Text
		$current:=Profiler_CallStack_GetCurrent
		UnitTest_Assert($current="my_method"; \
			"Spaces in tag should be replaced with underscores, got: "+$current)
		Profiler_STOP("my method")
		
		
	: ($action="Profiler_multiple_levels")
		Profiler_START("my method level 1")
		UnitTest_Assert(Profiler_CallStack_GetCurrent="my_method_level_1"; "expecting 'my_method_level_1', got '"+Profiler_CallStack_GetCurrent+"'")
		Profiler_START("my method level 2")
		UnitTest_Assert(Profiler_CallStack_GetCurrent="my_method_level_2"; "expecting 'my_method_level_2', got '"+Profiler_CallStack_GetCurrent+"'")
		Profiler_STOP("my method level 2")
		UnitTest_Assert(Profiler_CallStack_GetCurrent="my_method_level_1"; "expecting 'my_method_level_1', got '"+Profiler_CallStack_GetCurrent+"'")
		Profiler_STOP("my method level 1")
		
		
End case 
