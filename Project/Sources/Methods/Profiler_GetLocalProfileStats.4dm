//%attributes = {"invisible":true,"shared":true,"preemptive":"capable"}
// Profiler_GetLocalProfileStats () : profileStatsAsText
// Profiler_GetLocalProfileStats () : text
// 
// DESCRIPTION
//   This method returns the contents of
//   the profile arrays in a standard format.
//   Only the stats for the current process are returned.
//
#DECLARE()->$profile_stats_as_text : Text
If (Worker_inWorker)
	Init_GlobalTracking
	$profile_stats_as_text:=Performance_GetTrackingAsTSV("GLOBAL"; __Global_PerfObj)
Else 
	Init_ThreadSafe
	$profile_stats_as_text:=Performance_GetTrackingAsTSV("Local"; __PerfObj)
End if 
