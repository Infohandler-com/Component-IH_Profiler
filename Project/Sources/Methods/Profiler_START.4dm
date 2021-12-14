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
C_TEXT:C284($1; $profilerTag)  // name to track
C_TEXT:C284($2; $extraText)  // OPTIONAL; optional text
// ----------------------------------------------------
// HISTORY
//   Created by: DB (11/23/07)
//   Mod: DB (10/29/2010) - Track start time
//   Mod: DB (11/22/2010) - support performance tracking switch
//   Mod: DB (01/20/2011) - Method stack always being tracked
//   Mod: DB (05/22/2017) - Moved to v16 component
//   Mod: DB (2020-02-07) - use collection
// ----------------------------------------------------

If (Asserted:C1132((Count parameters:C259=1) | (Count parameters:C259=2)))
	$profilerTag:=Replace string:C233($1; " "; "_")
	If (Count parameters:C259=2)
		$extraText:=Replace string:C233($2; " "; "_")
	End if 
	
	C_COLLECTION:C1488(__STACK)
	Case of 
		: (__STACK=Null:C1517)  // first time being called, set everything up
			Init_ThreadSafe
			
		: (__STACK.length=0)  // has been called previously, but we are back to an empty stack
			Init_ThreadSafe(True:C214)  // Force everyting to get reset
	End case 
	
	
	C_OBJECT:C1216($event)
	$event:=New object:C1471
	$event.tag:=$profilerTag
	$event.extraText:=$extraText
	$event.start_ms:=Milliseconds:C459  // Holds the start time of the method call
	$event.wasteTime:=0  // Holds time spent on internal calls
	
	__STACK.push($event)  // Add our method to the call stack
	
	__incrementLevel:=__incrementLevel+1
End if 