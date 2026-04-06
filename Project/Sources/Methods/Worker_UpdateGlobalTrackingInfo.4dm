//%attributes = {"invisible":true,"preemptive":"capable"}
// Worker_UpdateGlobalTrackingInfo (performanceObj, flameObj)
// Worker_UpdateGlobalTrackingInfo (object, object)
//
// DESCRIPTION
//   Captures the performance information and adds it to
//   the global tracking objects.
//
#DECLARE($flameObj : Object; $performanceObj : Object)

If (Asserted:C1132(Count parameters:C259=2))
	C_OBJECT:C1216(__Global_PerfObj; __Global_PerfFlameObj)  // init by Init_GlobalTracking
	Init_GlobalTracking
	
	Performance_Global_AddTrackObj($performanceObj; __Global_PerfObj)
	Performance_Global_AddTrackObj($flameObj; __Global_PerfFlameObj)
End if 