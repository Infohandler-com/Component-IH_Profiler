//%attributes = {"invisible":true,"preemptive":"capable"}
// Init_GlobalTracking ({forced})
//
// DESCRIPTION
//   Routine that ensures that the global tracking
//   variables have all been defined.
//
#DECLARE($forceInit : Boolean)
// ----------------------------------------------------

var __Global_PerfObj; __Global_PerfFlameObj : Object

If (__Global_PerfObj=Null:C1517) || ($forceInit)
	__Global_PerfObj:={_numItems: 0}
End if 

If (__Global_PerfFlameObj=Null:C1517) || ($forceInit)
	__Global_PerfFlameObj:={_numItems: 0}
End if 