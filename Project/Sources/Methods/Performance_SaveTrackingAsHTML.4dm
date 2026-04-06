//%attributes = {"invisible":true,"preemptive":"capable"}
// Performance_SaveTrackingAsHTML (statType, performanceObj, filePath)
// Performance_SaveTrackingAsHTML (text, object, text)
//
// DESCRIPTION
//   
//
#DECLARE($statType : Text; $performanceObj : Object; $filePath : Text)

If (Asserted:C1132(Count parameters:C259=3))
	
	File_Delete($filePath)
	
	ARRAY TEXT:C222($objectPropertyNames; 0)
	OB GET PROPERTY NAMES:C1232($performanceObj; $objectPropertyNames)
	SORT ARRAY:C229($objectPropertyNames; >)
	
	C_TEXT:C284($html)
	$html:="<style> .red {color:red;}</style>"
	If ($statType="flame")
		$html+="<h1>Method Profiler Stats - Flamegraph</h1>"
	Else 
		$html+="<h1>Method Profiler Stats - Profile</h1>"
	End if 
	
	$html+="<table id=\"methodStats\" width=100% border=0>"
	$html+="<thead><tr>"
	$html+="<th>Method Name</th>"
	$html+="<th>Min (ms)</th>"
	$html+="<th>Avg (ms)</th>"
	$html+="<th>Max (ms)</th>"
	$html+="<th>Total (ms)</th>"
	$html+="<th>Call Count</th>"
	$html+="<th>Avg/Max Ratio</th>"
	$html+="<th>Max/Total Ratio</th>"
	$html+="</tr></thead>"
	
	C_LONGINT:C283($callCount)
	C_REAL:C285($vr_average; $vr_max; $vr_total; $vr_ratioTotal; $vr_min; $vr_ratioAvg)
	C_BOOLEAN:C305($vb_warnRatioTotal; $vb_warnAvg)
	$html+="<tbody>"
	
	C_TEXT:C284($tmpHTML; $methodName)
	C_LONGINT:C283($i; $rowNo)
	C_REAL:C285($vr_total; $vr_max; $vr_min; $vr_ratioAvg; $vr_ratioTotal)
	$tmpHTML:=""
	$rowNo:=0
	For ($i; 1; Size of array:C274($objectPropertyNames))
		If ($objectPropertyNames{$i}#"_numItems")
			$rowNo:=$rowNo+1
			$vr_total:=$performanceObj[$objectPropertyNames{$i}].total
			$callCount:=$performanceObj[$objectPropertyNames{$i}].callCount
			$vr_max:=$performanceObj[$objectPropertyNames{$i}].max
			$vr_min:=$performanceObj[$objectPropertyNames{$i}].min
			$methodName:=Replace string:C233($objectPropertyNames{$i}; ";"; ">")
			
			$vr_average:=$vr_total/$callCount
			If ($vr_max=0)
				$vr_ratioAvg:=0
			Else 
				$vr_ratioAvg:=$vr_average/$vr_max
			End if 
			If ($vr_total=0)
				$vr_ratioTotal:=0
			Else 
				$vr_ratioTotal:=$vr_max/$vr_total
			End if 
			
			$vb_warnRatioTotal:=False:C215
			$vb_warnAvg:=False:C215
			If ($callCount>1000) & ($vr_ratioTotal>0.3)
				$vb_warnRatioTotal:=True:C214
			End if 
			If ($callCount>10000) & ($vr_average>20)
				$vb_warnAvg:=True:C214
			End if 
			
			If (True:C214)  // output the HTML
				$tmpHTML+="<tr class="+Choose:C955((Mod:C98($rowNo; 2)=1); "a"; "b")+">"
				$tmpHTML+="<td>"+STR_HTML_Encode($methodName)+"</td>"  // Method Name"
				$tmpHTML+="<td>"+String:C10($vr_min; "###,###,###,##0")+"</td>"  // Min
				$tmpHTML+="<td"+Choose:C955(Num:C11($vb_warnAvg); ""; " class=\"red\"")+">"+String:C10($vr_average; "###,###,###,##0.0")+"</td>"  // Avg
				$tmpHTML+="<td>"+String:C10($vr_max; "###,###,###,##0")+"</td>"  // Max
				$tmpHTML+="<td>"+String:C10($vr_total; "###,###,###,##0")+"</td>"  // Total
				$tmpHTML+="<td>"+String:C10($callCount; "###,###,###,##0")+"</td>"  // Call Count
				$tmpHTML+="<td>"+String:C10(($vr_ratioAvg*100); "###,###,###,##0.0")+"%</td>"  // Avg/Max Ratio
				$tmpHTML+="<td"+Choose:C955(Num:C11($vb_warnRatioTotal); ""; " class=\"red\"")+">"+String:C10(($vr_ratioTotal*100); "###,###,###,##0.0")+"%</td>"  // Max/Total Ratio
				$tmpHTML+="</tr>"
			End if 
			
			If (Length:C16($tmpHTML)>2048)
				$html+=$tmpHTML
				$tmpHTML:=""
			End if 
		End if 
	End for 
	$html+=$tmpHTML
	
	$html+="</tbody>"
	$html+="</table>"
	TEXT TO DOCUMENT:C1237($filePath; $html)
End if 