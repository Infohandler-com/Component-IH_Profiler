//%attributes = {"invisible":true,"shared":true,"preemptive":"capable"}
// Profiler_CallStack_GetCurrent () : currentMethodName
// Profiler_CallStack_GetCurrent () : text
// 
// DESCRIPTION
//   Returns the most recent method name on the calling stack.
//
#DECLARE()->$vt_currentMethodName : Text
Init_ThreadSafe

If (__STACK.length>0)
	$vt_currentMethodName:=__STACK[__STACK.length-1].tag
End if 

If ($vt_currentMethodName="")  // Just in case, try to catch it this way.
	$vt_currentMethodName:=Error method
End if 

If ($vt_currentMethodName="")
	$vt_currentMethodName:="unknown method"
End if 
