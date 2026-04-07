//%attributes = {"invisible":true,"preemptive":"capable"}
// Performance_Global_AddTrackObj (performanceObj, globalPerformanceObj)
//
// DESCRIPTION
//   Adds the performance information provided into the
//   global performance object.
//
#DECLARE($performanceObj : Object; $globalPerformanceObj : Object)
// ----------------------------------------------------
ASSERT:C1129(Count parameters:C259=2)

ARRAY TEXT:C222($objectPropertyNames; 0)
OB GET PROPERTY NAMES:C1232($performanceObj; $objectPropertyNames)

var $i : Integer
For ($i; 1; Size of array:C274($objectPropertyNames))
	Case of 
		: ($objectPropertyNames{$i}="_numItems")  // Ignore this, just a counter
			
		: ($globalPerformanceObj[$objectPropertyNames{$i}]=Null:C1517)
			$globalPerformanceObj[$objectPropertyNames{$i}]:=$performanceObj[$objectPropertyNames{$i}]
			$globalPerformanceObj._numItems+=1
			
		Else 
			var $obj; $globalObj : Object
			$obj:=$performanceObj[$objectPropertyNames{$i}]
			$globalObj:=$globalPerformanceObj[$objectPropertyNames{$i}]
			
			If ($globalObj.min>$obj.min)
				$globalObj.min:=$obj.min
			End if 
			If ($globalObj.max<$obj.max)
				$globalObj.max:=$obj.max
			End if 
			$globalObj.total+=$obj.total
			$globalObj.callCount+=$obj.callCount
	End case 
End for 
