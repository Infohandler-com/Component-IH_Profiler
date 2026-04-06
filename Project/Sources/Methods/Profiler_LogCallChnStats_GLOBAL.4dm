//%attributes = {"invisible":true,"shared":true,"preemptive":"capable"}
// Profiler_LogCallChnStats_GLOBAL ()
// 
// DESCRIPTION
//   This method dumps to the log file the globally collected method call chain
//   stats of the profile arrays.
//
//   Dumps Columns: Call Chain, Call Count, Min, Avg, Max Total
//

CALL WORKER:C1389(Worker_GetProcessName; "Profiler_LogCallChainStats")
