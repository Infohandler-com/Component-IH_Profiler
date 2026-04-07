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

C_BOOLEAN:C305(__STACK_inited)
If (Not:C34(__STACK_inited))
	__STACK_inited:=True:C214
	
	C_LONGINT:C283(__incrementLevel)
	__incrementLevel:=0
	
	C_COLLECTION:C1488(__STACK)
	__STACK:=New collection:C1472  // stack used for the method calling chain
	
	C_OBJECT:C1216(__PerfObj; __PerfFlameObj)
	__PerfObj:=New object:C1471("_numItems"; 0)
	__PerfFlameObj:=New object:C1471("_numItems"; 0)
End if 
