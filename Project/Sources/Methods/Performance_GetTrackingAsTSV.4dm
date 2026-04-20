//%attributes = {"invisible":true,"preemptive":"capable"}
// Performance_GetTrackingAsTSV (statType, performanceObj) : csv
// Performance_GetTrackingAsTSV (text, object) : text
//
// DESCRIPTION
//   
//
#DECLARE($statType : Text; $performanceObj : Object)->$csv : Text

If (Asserted:C1132(Count parameters:C259=2))
	
	If ($performanceObj._numItems>1)
		ARRAY TEXT:C222($objectPropertyNames; 0)
		OB GET PROPERTY NAMES:C1232($performanceObj; $objectPropertyNames)
		SORT ARRAY:C229($objectPropertyNames; >)
		
		$csv+="\rMETHOD NAME ("+$statType+")\t"
		$csv+="Call Count\t"
		$csv+="Min (ms)\t"
		$csv+="Avg (ms)\t"
		$csv+="Max (ms)\t"
		$csv+="Total (ms)\r"
		
		var $i : Integer
		For ($i; 1; Size of array:C274($objectPropertyNames))
			If ($objectPropertyNames{$i}#"_NumItems")
				$csv+=$objectPropertyNames{$i}+Char:C90(Tab:K15:37)
				$csv+=String:C10($performanceObj[$objectPropertyNames{$i}].callCount)+Char:C90(Tab:K15:37)
				$csv+=String:C10($performanceObj[$objectPropertyNames{$i}].min)+Char:C90(Tab:K15:37)
				If ($performanceObj[$objectPropertyNames{$i}].total>0)
					$csv+=String:C10($performanceObj[$objectPropertyNames{$i}].total/$performanceObj[$objectPropertyNames{$i}].callCount; "###,###,###,###,##0.00")+Char:C90(Tab:K15:37)
				Else 
					$csv+="0"+Char:C90(Tab:K15:37)
				End if 
				$csv+=String:C10($performanceObj[$objectPropertyNames{$i}].max)+Char:C90(Tab:K15:37)
				$csv+=String:C10($performanceObj[$objectPropertyNames{$i}].total)+Char:C90(Carriage return:K15:38)  //   Mod: DB (01/28/2014)
			End if 
		End for 
		
		$csv+="\r\r"
	End if 
End if 
