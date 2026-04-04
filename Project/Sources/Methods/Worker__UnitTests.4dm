//%attributes = {"invisible":true,"preemptive":"incapable"}
// Worker__UnitTests ($action)
// Unit tests for Worker_GetProcessName

#DECLARE($action : Text)

Case of 
	: ($action="RunTests")
		UnitTest_RunTest("Worker_GetProcessName_ReturnsWProfiler")
		
	: ($action="Worker_GetProcessName_ReturnsWProfiler")
		var $name : Text
		$name:=Worker_GetProcessName
		UnitTest_Assert($name="W_Profiler"; "Worker process name should be 'W_Profiler', got: "+$name)
		
End case 
