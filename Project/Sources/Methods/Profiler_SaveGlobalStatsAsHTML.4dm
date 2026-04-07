//%attributes = {"invisible":true,"shared":true,"preemptive":"capable"}
// Profiler_SaveGlobalStatsAsHTML (statsToSave; filePath) 
// 
// DESCRIPTION
//   Saves the globally collected stats to the file.
//   $1 can be "flame" or "profile".
//
#DECLARE($vt_statsToSave : Text; $vt_filePath : Text)
// ----------------------------------------------------
ASSERT:C1129(Count parameters:C259=2)

If (Asserted:C1132(($vt_statsToSave="flame") || ($vt_statsToSave="profile"); "Expecting $2 to be \"flame\" or \"profile\".")) & ($vt_filePath#"")
	CALL WORKER:C1389(Worker_GetProcessName; Formula:C1597(Worker_SaveStatsAsHTML).source; $vt_statsToSave; $vt_filePath)
End if 