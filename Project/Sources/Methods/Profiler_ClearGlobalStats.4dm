//%attributes = {"invisible":true,"shared":true,"preemptive":"capable"}
// Profiler_ClearGlobalStats ()
// 
// DESCRIPTION
//   Clears the global stats. Any captured stats are logged
//   prior to clearing.
//
Profiler_LogMethodStats_GLOBAL
Profiler_LogCallChnStats_GLOBAL
Profiler_LogFlameStats_GLOBAL

CALL WORKER:C1389(Worker_GetProcessName; "Init_GlobalTracking"; True:C214)