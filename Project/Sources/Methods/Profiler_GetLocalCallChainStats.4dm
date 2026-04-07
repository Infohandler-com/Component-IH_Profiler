//%attributes = {"invisible":true,"shared":true,"preemptive":"capable"}
// Profiler_GetLocalCallChainStats () : flameStatsAsText
// 
// DESCRIPTION
//   This method returns the contents of
//   the profile arrays in a format that support flamegraphs.
//   Only the stats for the current process are returned.
//
#DECLARE()->$flame_stats_as_text : Text
// ----------------------------------------------------

If (Worker_inWorker)
	Init_GlobalTracking
	$flame_stats_as_text:=Performance_GetTrackingAsTSV("GLOBAL"; __Global_PerfFlameObj)
	
Else 
	Init_ThreadSafe
	$flame_stats_as_text:=Performance_GetTrackingAsTSV("Local"; __PerfFlameObj)
End if 
