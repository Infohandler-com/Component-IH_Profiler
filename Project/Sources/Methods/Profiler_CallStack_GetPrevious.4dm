//%attributes = {"invisible":true,"shared":true,"preemptive":"capable"}
// Profiler_CallStack_GetPrevious () : currentMethodName
// Profiler_CallStack_GetPrevious () : text
// 
// DESCRIPTION
//   Returns the most recent method name on the calling stack.
//
#DECLARE()->$vt_previousMethodName : Text
Init_ThreadSafe

If (__STACK.length>1)
	$vt_previousMethodName:=__STACK[__STACK.length-2].tag
End if 
