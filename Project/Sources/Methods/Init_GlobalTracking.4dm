//%attributes = {"invisible":true,"preemptive":"capable"}
// Init_GlobalTracking ({forced})
// Init_GlobalTracking ({boolean})
//
// DESCRIPTION
//   Routine that ensures that the global tracking
//   variables have all been defined.
//
C_BOOLEAN:C305($1)
// ----------------------------------------------------
// HISTORY
//   Created by: Dani Beaubien (04/06/2020)
// ----------------------------------------------------

C_BOOLEAN:C305($forceInit)
If (Count parameters:C259=1)
	$forceInit:=$1  // force a refresh?
End if 

C_OBJECT:C1216(__Global_PerfObj; __Global_PerfFlameObj)

If (__Global_PerfObj=Null:C1517) | ($forceInit)
	__Global_PerfObj:=New object:C1471
	__Global_PerfObj._numItems:=0
End if 

If (__Global_PerfFlameObj=Null:C1517) | ($forceInit)
	__Global_PerfFlameObj:=New object:C1471
	__Global_PerfFlameObj._numItems:=0
End if 