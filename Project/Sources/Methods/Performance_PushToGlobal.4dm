//%attributes = {"invisible":true,"preemptive":"capable"}
// Performance_PushToGlobal ()
//
// DESCRIPTION
//   This method sends the performance information
//   captured in the current process to the global
//   performance stats.
//
// ----------------------------------------------------

var __PerfObj; __PerfFlameObj : Object  // defined by Init_ThreadSafe

CALL WORKER:C1389(Worker_GetProcessName; "Worker_UpdateGlobalTrackingInfo"; __PerfObj; __PerfFlameObj)

