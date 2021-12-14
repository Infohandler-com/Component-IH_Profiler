//%attributes = {"invisible":true,"preemptive":"capable"}
// Performance_PushToGlobal ()
//
// DESCRIPTION
//   This method sends the performance information
//   captured in the current process to the global
//   performance stats.
//
// ----------------------------------------------------
// HISTORY
//   Created by: Dani Beaubien (04/06/2020)
// ----------------------------------------------------

C_OBJECT:C1216(__PerfObj; __PerfFlameObj)  // defined by Init_ThreadSafe

CALL WORKER:C1389(Worker_GetProcessName; "Worker_UpdateGlobalTrackingInfo"; __PerfObj; __PerfFlameObj)

