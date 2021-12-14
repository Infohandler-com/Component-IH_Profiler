//%attributes = {"invisible":true,"preemptive":"capable"}
// Performance_Global_AddTrackObj (performanceObj, globalPerformanceObj)
// Performance_Global_AddTrackObj (object, object)
//
// DESCRIPTION
//   Adds the performance information provided into the
//   global performance object.
//
C_OBJECT:C1216($1; $performanceObj)
C_OBJECT:C1216($2; $globalPerformanceObj)
// ----------------------------------------------------
// HISTORY
//   Created by: Dani Beaubien (04/06/2020)
// ----------------------------------------------------

If (Asserted:C1132(Count parameters:C259=2))
	$performanceObj:=$1
	$globalPerformanceObj:=$2
	
	ARRAY TEXT:C222($objectPropertyNames; 0)
	OB GET PROPERTY NAMES:C1232($performanceObj; $objectPropertyNames)
	
	C_LONGINT:C283($i)
	For ($i; 1; Size of array:C274($objectPropertyNames))
		Case of 
			: ($objectPropertyNames{$i}="_numItems")  // Ignore this, just a counter
				
			: ($globalPerformanceObj[$objectPropertyNames{$i}]=Null:C1517)
				$globalPerformanceObj[$objectPropertyNames{$i}]:=$performanceObj[$objectPropertyNames{$i}]
				$globalPerformanceObj._numItems:=$globalPerformanceObj._numItems+1
				
			Else 
				C_OBJECT:C1216($obj; $globalObj)
				$obj:=$performanceObj[$objectPropertyNames{$i}]
				$globalObj:=$globalPerformanceObj[$objectPropertyNames{$i}]
				
				If ($globalObj.min>$obj.min)
					$globalObj.min:=$obj.min
				End if 
				If ($globalObj.max<$obj.max)
					$globalObj.max:=$obj.max
				End if 
				$globalObj.total:=$globalObj.total+$obj.total
				$globalObj.callCount:=$globalObj.callCount+$obj.callCount
		End case 
	End for 
	
End if 
