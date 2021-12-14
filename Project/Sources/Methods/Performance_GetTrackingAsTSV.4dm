//%attributes = {"invisible":true,"preemptive":"capable"}
// Performance_GetTrackingAsTSV (statType, performanceObj) : csv
// Performance_GetTrackingAsTSV (text, object) : text
//
// DESCRIPTION
//   
//
C_TEXT:C284($1; $statType)
C_OBJECT:C1216($2; $performanceObj)
C_TEXT:C284($0; $csv)
// ----------------------------------------------------
// HISTORY
//   Created by: Dani Beaubien (04/06/2020)
// ----------------------------------------------------

$csv:=""
If (Asserted:C1132(Count parameters:C259=2))
	$statType:=$1
	$performanceObj:=$2
	
	If ($performanceObj._numItems>1)
		ARRAY TEXT:C222($objectPropertyNames; 0)
		OB GET PROPERTY NAMES:C1232($performanceObj; $objectPropertyNames)
		SORT ARRAY:C229($objectPropertyNames; >)
		
		$csv:=$csv+"\rMETHOD NAME ("+$statType+")\t"
		$csv:=$csv+"Call Count\t"
		$csv:=$csv+"Min (ms)\t"
		$csv:=$csv+"Avg (ms)\t"
		$csv:=$csv+"Max (ms)\t"
		$csv:=$csv+"Total (ms)\r"
		
		C_LONGINT:C283($i)
		For ($i; 1; Size of array:C274($objectPropertyNames))
			If ($objectPropertyNames{$i}#"_NumItems")
				$csv:=$csv+$objectPropertyNames{$i}+Char:C90(Tab:K15:37)
				$csv:=$csv+String:C10($performanceObj[$objectPropertyNames{$i}].callCount)+Char:C90(Tab:K15:37)
				$csv:=$csv+String:C10($performanceObj[$objectPropertyNames{$i}].min)+Char:C90(Tab:K15:37)
				If ($performanceObj[$objectPropertyNames{$i}].total>0)
					$csv:=$csv+String:C10($performanceObj[$objectPropertyNames{$i}].total/$performanceObj[$objectPropertyNames{$i}].callCount; "###,###,###,###,##0.00")+Char:C90(Tab:K15:37)
				Else 
					$csv:=$csv+"0"+Char:C90(Tab:K15:37)
				End if 
				$csv:=$csv+String:C10($performanceObj[$objectPropertyNames{$i}].max)+Char:C90(Tab:K15:37)
				$csv:=$csv+String:C10($performanceObj[$objectPropertyNames{$i}].total)+Char:C90(Carriage return:K15:38)  //   Mod: DB (01/28/2014)
			End if 
		End for 
		
		$csv:=$csv+"\r\r"
	End if 
End if 
$0:=$csv