//%attributes = {"invisible":true,"shared":true,"preemptive":"capable"}
// Profiler_LogFlameStats ({module}) : statsAsText
// Profiler_LogFlameStats ({text}) : text
// 
// DESCRIPTION
//   This method stores the profiling stats in a flamegraph
//   safe format to the specified module file.
//
C_TEXT:C284($1; $vt_moduleName)
// ----------------------------------------------------
// HISTORY
//   Created by: DB (05/10/11)
//   Mod: DB (01/28/2014) - Added Total to output
//   Mod by: Dani Beaubien (03/28/2014) - Changed output to be "-"'s
// ----------------------------------------------------

If (Asserted:C1132(Count parameters:C259<=1))
	If (Count parameters:C259=1)
		$vt_moduleName:="Profiler Flamegraph Unfolded - "+$1
	End if 
	If ($vt_moduleName="")
		$vt_moduleName:="Profiler Flamegraph Unfolded"
	End if 
	
	C_TEXT:C284($vt_buffer)
	$vt_buffer:=""
	
	C_OBJECT:C1216($performanceObj)
	If (Worker_inWorker)
		Init_GlobalTracking
		$performanceObj:=__Global_PerfFlameObj
	Else 
		Init_ThreadSafe
		$performanceObj:=__PerfFlameObj
	End if 
	
	If ($performanceObj._numItems>1)
		ARRAY TEXT:C222($objectPropertyNames; 0)
		OB GET PROPERTY NAMES:C1232($performanceObj; $objectPropertyNames)
		SORT ARRAY:C229($objectPropertyNames; >)
		
		C_LONGINT:C283($i)
		C_REAL:C285($vr_totalTime)
		For ($i; 1; Size of array:C274($objectPropertyNames))
			If ($objectPropertyNames{$i}#"_NumItems")
				$vr_totalTime:=$performanceObj[$objectPropertyNames{$i}].total*10
				
				If ($vr_totalTime=0)  // force to be non-zero
					$vr_totalTime:=1
				End if 
				$vt_buffer:=$vt_buffer+$objectPropertyNames{$i}+" "+String:C10($vr_totalTime)+Char:C90(Line feed:K15:40)
				
				If (Length:C16($vt_buffer)>5120)
					LogNamed_AppendToFile_Quiet($vt_moduleName; $vt_buffer; "noTimeStamp"; "noProc#")
					$vt_buffer:=""
				End if 
				
			End if 
		End for 
		
		If ($vt_buffer#"")
			LogNamed_AppendToFile_Quiet($vt_moduleName; $vt_buffer; "noTimeStamp"; "noProc#")
		End if 
	End if 
	
End if 
