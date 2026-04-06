//%attributes = {"invisible":true,"shared":true,"preemptive":"capable"}
// Profiler_LogFlameStats_GLOBAL ()
// 
// DESCRIPTION
//   This method stores the globally collected profiling stats in a flamegraph
//   safe format to the specified module file.
//

CALL WORKER:C1389(Worker_GetProcessName; "Profiler_LogFlameStats"; "GLOBAL")
