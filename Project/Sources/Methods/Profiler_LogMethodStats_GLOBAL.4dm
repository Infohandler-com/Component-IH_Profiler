//%attributes = {"invisible":true,"shared":true,"preemptive":"capable"}
// Profiler_LogMethodStats_GLOBAL ()
// 
// DESCRIPTION
//   This method dumps to the log file the globally collected method
//   stats of the profile arrays.
//
//   Dumps Columns: Method Name, Call Count, Min, Avg, Max Total
//

CALL WORKER:C1389(Worker_GetProcessName; "Profiler_LogMethodStats")
