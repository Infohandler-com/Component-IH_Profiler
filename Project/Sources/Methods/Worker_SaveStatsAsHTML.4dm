//%attributes = {"invisible":true,"preemptive":"capable"}
// Worker_SaveStatsAsHTML (parm1; parm2; ...) : result
// Worker_SaveStatsAsHTML (parm1; parm2; ...) : result
// 
// DESCRIPTION
//   Saves the collected stats to the file.
//   $1 can be "flame" or "profile".
//
C_TEXT:C284($1; $statType)
C_TEXT:C284($2; $filePath)
// ----------------------------------------------------
// HISTORY
//   Created by: DB (05/25/2017)
//   Mod: DB (07/01/2017) - Task 3897
// ----------------------------------------------------

ASSERT:C1129(Count parameters:C259=2)
$statType:=$1
$filePath:=$2

If (Asserted:C1132(($statType="flame") | ($statType="profile"); "Expecting $2 to be \"flame\" or \"profile\".")) & ($filePath#"")
	File_Delete($filePath)
	
	Init_GlobalTracking
	
	If ($statType="profile")
		Performance_SaveTrackingAsHTML($statType; __Global_PerfObj; $filePath)
	Else 
		Performance_SaveTrackingAsHTML($statType; __Global_PerfFlameObj; $filePath)
	End if 
End if 
