//%attributes = {"invisible":true,"preemptive":"capable"}
// Init_ThreadSafe ({forced})
// Init_ThreadSafe ({boolean})
// 
// DESCRIPTION
//   Thread Safe.
//   Initalized the process variables.
//
#DECLARE($forced : Boolean)

If (Count parameters:C259=1)
	If ($forced)  // force a refresh?
		__STACK_inited:=False:C215
	End if 
End if 

var __STACK_inited : Boolean
If (Not:C34(__STACK_inited))
	__STACK_inited:=True:C214
	
	var __incrementLevel : Integer
	__incrementLevel:=0
	
	var __STACK : Collection
	__STACK:=New collection:C1472  // stack used for the method calling chain
	
	var __PerfObj; __PerfFlameObj : Object
	__PerfObj:=New object:C1471("_numItems"; 0)
	__PerfFlameObj:=New object:C1471("_numItems"; 0)
End if 
