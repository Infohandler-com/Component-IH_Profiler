//%attributes = {"invisible":true,"shared":true,"preemptive":"capable"}
// Profiler_START (profilerTag {;optionalText})
// Profiler_START (text {;text})
// 
// DESCRIPTION
//   Used to capture the start of a segment of code that
//   is to be monitored. Each start call must be balanced
//   with a stop call with exact same params.
//
//   NOTE: Spaces in $1 & $2 are replaced by "_".
//
#DECLARE($profilerTag : Text; $extraText : Text)

If (Asserted:C1132((Count parameters:C259=1) || (Count parameters:C259=2)))
	$profilerTag:=Replace string:C233($profilerTag; " "; "_")
	If (Count parameters:C259=2)
		$extraText:=Replace string:C233($extraText; " "; "_")
	End if 
	
	var __STACK : Collection
	Case of 
		: (__STACK=Null:C1517)  // first time being called, set everything up
			Init_ThreadSafe
			
		: (__STACK.length=0)  // has been called previously, but we are back to an empty stack
			Init_ThreadSafe(True:C214)  // Force everyting to get reset
	End case 
	
	
	var $event : Object
	$event:=New object:C1471
	$event.tag:=$profilerTag
	$event.extraText:=$extraText
	$event.start_ms:=Milliseconds:C459  // Holds the start time of the method call
	$event.wasteTime:=0  // Holds time spent on internal calls
	
	__STACK.push($event)  // Add our method to the call stack
	
	__incrementLevel+=1
End if 