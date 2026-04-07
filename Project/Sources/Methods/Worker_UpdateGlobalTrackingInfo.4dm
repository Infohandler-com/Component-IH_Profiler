//%attributes = {"invisible":true,"preemptive":"capable"}
// Worker_UpdateGlobalTrackingInfo (performanceObj, flameObj)
//
// DESCRIPTION
//   Captures the performance information and adds it to
//   the global tracking objects.
//
#DECLARE($performanceObj : Object; $flameObj : Object)
// ----------------------------------------------------
ASSERT:C1129(Count parameters:C259=2)

var __Global_PerfObj; __Global_PerfFlameObj : Object  // init by Init_GlobalTracking
Init_GlobalTracking

If ($performanceObj#Null:C1517)
	Performance_Global_AddTrackObj($performanceObj; __Global_PerfObj)
End if 

If ($flameObj#Null:C1517)
	Performance_Global_AddTrackObj($flameObj; __Global_PerfFlameObj)
End if 