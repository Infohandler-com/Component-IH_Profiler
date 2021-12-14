//%attributes = {"invisible":true,"shared":true,"preemptive":"capable"}
// Profiler_STOP (profilerTag {;optionalText})
// Profiler_STOP (text {;text})
// 
// DESCRIPTION
//   Used to capture the end of a segment of code that
//   is to be monitored. Each start call must be balanced
//   with a stop call with exact same params.
//
//   NOTE: Spaces in $1 & $2 are replaced by "_".
//
C_TEXT:C284($1; $profilerTag)  // method name
C_TEXT:C284($2; $extraText)  // Optional stuff
// ----------------------------------------------------
// HISTORY
//   Created by: DB (11/23/07)
//   Mod: DB (10/26/2010) - Make sure that we get the method name that we are expecting
//   Mod: DB (11/22/2010) - support performance tracking switch
//   Mod: DB (01/20/2011) - Improved Performance of this method, significantly faster
//   Mod: DB (01/28/2014) - Add tracking globally
//   Mod: DB (05/22/2017) - Moved to v16 component
//   Mod: DB (2020-02-07) - use collection
// ----------------------------------------------------

If (Asserted:C1132((Count parameters:C259=1) | (Count parameters:C259=2)))
	$profilerTag:=Replace string:C233($1; " "; "_")
	If (Count parameters:C259=2)
		$extraText:=Replace string:C233($2; " "; "_")
	End if 
	
	OnErr_Install_Handler("OnErr_GENERIC_Profiler")
	
	C_TEXT:C284($fullProfilerTag)
	$fullProfilerTag:=$profilerTag
	If ($extraText#"")
		$fullProfilerTag:=$fullProfilerTag+"("+$extraText+")"
	End if 
	
	Init_ThreadSafe
	
	If (__STACK.length>0)
		C_OBJECT:C1216($event)
		$event:=__STACK.pop()
		
		// # Make sure that the STOPPED method matches what is expected
		If ($profilerTag#$event.tag) | ($extraText#$event.extraText)
			C_TEXT:C284($errorLogMessage)
			$errorLogMessage:=" called with $1 = '"+$profilerTag+"'"
			If ($extraText#"")
				$errorLogMessage:=$errorLogMessage+" and $2 = '"+$extraText+"'"
			End if 
			$errorLogMessage:=$errorLogMessage+" but expecting $1 = '"+$event.tag+"'"
			If ($event.extraText#"")
				$errorLogMessage:=$errorLogMessage+" and $2 = '"+$event.extraText+"'"
			End if 
			LogNamed_AppendToFile("On Err Trigger"; Current method name:C684+$errorLogMessage)
		End if 
		
		C_REAL:C285($stoppedAtMilliseconds)
		$stoppedAtMilliseconds:=Milliseconds:C459
		
		// # Track the time
		C_LONGINT:C283($timeSpentInMethod)
		$timeSpentInMethod:=$stoppedAtMilliseconds-$event.start_ms  // time between start & end
		$timeSpentInMethod:=$timeSpentInMethod-$event.wasteTime  // remove the child method's time
		
		C_LONGINT:C283($size)
		$size:=__STACK.length
		If ($size>0)  // add our execute time to the calling parent method
			__STACK[$size-1].wasteTime:=__STACK[$size-1].wasteTime+$event.wasteTime  // add child method times
			__STACK[$size-1].wasteTime:=__STACK[$size-1].wasteTime+$timeSpentInMethod  // add current method times
		End if 
		
		// Track by method name
		Performance_UpdateTrackingObj(__PerfObj; $fullProfilerTag; $timeSpentInMethod)
		
		// Track by flamegraph name
		C_TEXT:C284($vt_MethodName_FlameGraph)
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
End if 