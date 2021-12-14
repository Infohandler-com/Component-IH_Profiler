//%attributes = {"invisible":true,"shared":true,"preemptive":"capable"}
// Profiler_GetLocalProfileStats () : profileStatsAsText
// Profiler_GetLocalProfileStats () : text
// 
// DESCRIPTION
//   This method returns the contents of
//   the profile arrays in a standard format.
//   Only the stats for the current process are returned.
//
C_TEXT:C284($0)
// ----------------------------------------------------
// HISTORY
//   Created by: DB (05/24/2017)
// ----------------------------------------------------

If (Worker_inWorker)
	Init_GlobalTracking
	$0:=Performance_GetTrackingAsTSV("GLOBAL"; __Global_PerfObj)
Else 
	Init_ThreadSafe
	$0:=Performance_GetTrackingAsTSV("Local"; __PerfObj)
End if 
