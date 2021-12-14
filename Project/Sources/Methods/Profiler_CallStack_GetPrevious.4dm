//%attributes = {"invisible":true,"shared":true,"preemptive":"capable"}
// Profiler_CallStack_GetPrevious () : currentMethodName
// Profiler_CallStack_GetPrevious () : text
// 
// DESCRIPTION
//   Returns the most recent method name on the calling stack.
//
C_TEXT:C284($0; $vt_previousMethodName)
// ----------------------------------------------------
// HISTORY
//   Created by: DB (05/24/2017)
// ----------------------------------------------------

Init_ThreadSafe

If (__STACK.length>1)
	$0:=__STACK[__STACK.length-2].tag
End if 

$0:=$vt_previousMethodName