//%attributes = {"invisible":true,"shared":true,"preemptive":"capable"}
// Profiler_GetLocalCallChainStats () : flameStatsAsText
// Profiler_GetLocalCallChainStats () : text
// 
// DESCRIPTION
//   This method returns the contents of
//   the profile arrays in a format that support flamegraphs.
//   Only the stats for the current process are returned.
//
C_TEXT:C284($0)
// ----------------------------------------------------
// HISTORY
//   Created by: DB (05/24/2017)
// ----------------------------------------------------

If (Worker_inWorker)
	Init_GlobalTracking
	$0:=Performance_GetTrackingAsTSV("GLOBAL"; __Global_PerfFlameObj)
Else 
	Init_ThreadSafe
	$0:=Performance_GetTrackingAsTSV("Local"; __PerfFlameObj)
End if 
