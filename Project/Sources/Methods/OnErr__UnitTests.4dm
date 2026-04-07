//%attributes = {"invisible":true,"preemptive":"incapable"}
// OnErr__UnitTests ($action)
// Unit tests for OnErr_ClearError, OnErr_GetLastError,
// OnErr_GetLastErrorMessages, and OnErr_Install_Handler

#DECLARE($action : Text)

Case of 
	: ($action="RunTests")
		UnitTest_RunTest("OnErr_ClearError_ResetsErrorCode")
		UnitTest_RunTest("OnErr_GetLastError_ReturnsZeroAfterClear")
		UnitTest_RunTest("OnErr_GetLastErrorMessages_ReturnsEmptyAfterClear")
		UnitTest_RunTest("OnErr_Install_Handler_PushAndRestore")
		UnitTest_RunTest("OnErr_Install_Handler_EmptyParamRestoresPrevious")
		
	: ($action="Setup")
		OnErr_ClearError  // Ensure clean error state before each test
		
	: ($action="TearDown")
		OnErr_ClearError  // Clean up error state after each test
		
	: ($action="OnErr_ClearError_ResetsErrorCode")
		// After ClearError, gError should be 0
		OnErr_ClearError
		var $errCode : Integer
		$errCode:=OnErr_GetLastError
		UnitTest_Assert($errCode=0; "gError should be 0 after OnErr_ClearError, got: "+String:C10($errCode))
		
	: ($action="OnErr_GetLastError_ReturnsZeroAfterClear")
		OnErr_ClearError
		UnitTest_Assert(OnErr_GetLastError=0; "OnErr_GetLastError should return 0 immediately after ClearError")
		
	: ($action="OnErr_GetLastErrorMessages_ReturnsEmptyAfterClear")
		OnErr_ClearError
		var $msgs : Text
		$msgs:=OnErr_GetLastErrorMessages
		UnitTest_Assert($msgs=""; "OnErr_GetLastErrorMessages should return empty string after ClearError, got: "+$msgs)
		
	: ($action="OnErr_Install_Handler_PushAndRestore")
		// Push a handler and verify it is installed
		var $originalHandler : Text
		$originalHandler:=Method called on error:C704
		
		OnErr_Install_Handler("OnErr_GENERIC_Profiler")
		var $installedHandler : Text
		$installedHandler:=Method called on error:C704
		UnitTest_Assert($installedHandler="OnErr_GENERIC_Profiler"; \
			"Handler should be 'OnErr_GENERIC_Profiler' after install, got: "+$installedHandler)
		
		// Restore previous handler
		OnErr_Install_Handler("")
		var $restoredHandler : Text
		$restoredHandler:=Method called on error:C704
		UnitTest_Assert($restoredHandler=$originalHandler; \
			"Handler should be restored to original after empty-param call, got: "+$restoredHandler)
		
	: ($action="OnErr_Install_Handler_EmptyParamRestoresPrevious")
		// Stack-based: push two handlers, pop both, verify restoration
		var $original : Text
		$original:=Method called on error:C704
		
		OnErr_Install_Handler("OnErr_GENERIC_Profiler")
		OnErr_Install_Handler("OnErr_GENERIC_Profiler_Minimal")
		UnitTest_Assert(Method called on error:C704="OnErr_GENERIC_Profiler_Minimal"; \
			"Second pushed handler should be active")
		
		OnErr_Install_Handler("")  // pop to OnErr_GENERIC_Profiler
		UnitTest_Assert(Method called on error:C704="OnErr_GENERIC_Profiler"; \
			"After one pop, first handler should be active")
		
		OnErr_Install_Handler("")  // pop to original
		UnitTest_Assert(Method called on error:C704=$original; \
			"After two pops, original handler should be restored")
		
End case 
