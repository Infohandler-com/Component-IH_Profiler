//%attributes = {"invisible":true,"preemptive":"incapable"}
// UnitTest_Setup_IHProfiler
//
// This is the place to setup your testcases

UnitTest_Init("all_soft")

// IH_Profiler component test cases
UnitTest_AddTestCase("Array__UnitTests")
UnitTest_AddTestCase("Date__UnitTests")
UnitTest_AddTestCase("File__UnitTests")
UnitTest_AddTestCase("Folder__UnitTests")
UnitTest_AddTestCase("STR__UnitTests")
UnitTest_AddTestCase("OnErr__UnitTests")
UnitTest_AddTestCase("Performance__UnitTests")
UnitTest_AddTestCase("Profiler__UnitTests")
UnitTest_AddTestCase("Worker__UnitTests")
UnitTest_AddTestCase("Init__UnitTests")

If (Structure file:C489(*)=Structure file:C489)  // Only open dialog if this structure is the host
	UnitTest_ShowDialog
End if 