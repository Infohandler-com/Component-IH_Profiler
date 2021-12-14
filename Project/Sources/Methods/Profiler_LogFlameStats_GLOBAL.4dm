//%attributes = {"invisible":true,"shared":true,"preemptive":"capable"}
// Profiler_LogFlameStats_GLOBAL ()
// 
// DESCRIPTION
//   This method stores the globally collected profiling stats in a flamegraph
//   safe format to the specified module file.
//
If (False:C215)
	// ----------------------------------------------------
	// HISTORY
	//   Created by: DB (05/24/2017)
	// ----------------------------------------------------
End if 

CALL WORKER:C1389(Worker_GetProcessName; "Profiler_LogFlameStats"; "GLOBAL")
