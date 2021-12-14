//%attributes = {"invisible":true,"shared":true}
// Profiler_SaveProcessStatsAsHTML (statType; filePath) 
// Profiler_SaveProcessStatsAsHTML (text; text) 
// 
// DESCRIPTION
//   Saves the collected stats for the current processes to the file.
//   $1 can be "flame" or "profile".
//
C_TEXT:C284($1; $statType)
C_TEXT:C284($2; $filePath)
// ----------------------------------------------------
// HISTORY
//   Created by: DB (05/25/2017)
// ----------------------------------------------------

If (Asserted:C1132(Count parameters:C259=2))
	$statType:=$1
	$filePath:=$2
	
	If (Asserted:C1132(($statType="flame") | ($statType="profile"); "Expecting $2 to be \"flame\" or \"profile\".")) & ($filePath#"")
		Init_ThreadSafe
		
		Case of 
			: ($statType="profile") & (__PerfObj._numItems>0)
				Performance_SaveTrackingAsHTML($statType; __PerfObj; $filePath)
				
			: ($statType="flame") & (__PerfFlameObj._numItems>0)
				Performance_SaveTrackingAsHTML($statType; __PerfFlameObj; $filePath)
				
			Else 
				// do nothing
		End case 
	End if 
	
End if 