//%attributes = {"invisible":true,"shared":true,"preemptive":"capable"}
// Profiler_STOP (profilerTag {;optionalText})
// 
// DESCRIPTION
//   Used to capture the end of a segment of code that
//   is to be monitored. Each start call must be balanced
//   with a stop call with exact same params.
//
//   NOTE: Spaces in $1 & $2 are replaced by "_".
//
#DECLARE($profilerTag : Text; $extraText : Text)
// ----------------------------------------------------
ASSERT:C1129((Count parameters:C259=1) || (Count parameters:C259=2))

$profilerTag:=Replace string:C233($profilerTag; " "; "_")
If (Count parameters:C259=2)
	$extraText:=Replace string:C233($extraText; " "; "_")
End if 

OnErr_Install_Handler("OnErr_GENERIC_Profiler")

var $fullProfilerTag : Text
$fullProfilerTag:=$profilerTag
If ($extraText#"")
	$fullProfilerTag:=$fullProfilerTag+"("+$extraText+")"
End if 

Init_ThreadSafe

If (__STACK.length>0)
	var $event : Object
	$event:=__STACK.pop()
	
	// # Make sure that the STOPPED method matches what is expected
	If ($profilerTag#$event.tag) | ($extraText#$event.extraText)
		var $errorLogMessage : Text
		$errorLogMessage:=" called with $1 = '"+$profilerTag+"'"
		If ($extraText#"")
			$errorLogMessage+=" and $2 = '"+$extraText+"'"
		End if 
		$errorLogMessage+=" but expecting $1 = '"+$event.tag+"'"
		If ($event.extraText#"")
			$errorLogMessage+=" and $2 = '"+$event.extraText+"'"
		End if 
		LogNamed_AppendToFile("On Err Trigger"; Current method name:C684+$errorLogMessage)
	End if 
	
	var $stoppedAtMilliseconds : Real
	$stoppedAtMilliseconds:=Milliseconds:C459
	
	// # Track the time
	var $timeSpentInMethod : Integer
	$timeSpentInMethod:=$stoppedAtMilliseconds-$event.start_ms  // time between start & end
	$timeSpentInMethod-=$event.wasteTime  // remove the child method's time
	
	var $size : Integer
	$size:=__STACK.length
	If ($size>0)  // add our execute time to the calling parent method
		__STACK[$size-1].wasteTime:=__STACK[$size-1].wasteTime+$event.wasteTime  // add child method times
		__STACK[$size-1].wasteTime:=__STACK[$size-1].wasteTime+$timeSpentInMethod  // add current method times
	End if 
	
	// Track by method name
	Performance_UpdateTrackingObj(__PerfObj; $fullProfilerTag; $timeSpentInMethod)
	
	// Track by flamegraph name
	var $vt_MethodName_FlameGraph : Text
	$vt_MethodName_FlameGraph:=STR_GetFlameGraphNameFromStack($fullProfilerTag; __STACK)
	Performance_UpdateTrackingObj(__PerfFlameObj; $vt_MethodName_FlameGraph; $timeSpentInMethod)
	
End if 

// Deal with tab levels
__incrementLevel:=__incrementLevel-1
If (__incrementLevel<0)
	Log_ERR(Current method name:C684+" has and __incrementLevel of "+String:C10(__incrementLevel); "Process")
	__incrementLevel:=0
End if 

// If this STOP is the last one from the stack, push to global tracking
If (__STACK.length=0) & (__PerfObj._numItems>0)
	Performance_PushToGlobal
End if 

OnErr_Install_Handler
