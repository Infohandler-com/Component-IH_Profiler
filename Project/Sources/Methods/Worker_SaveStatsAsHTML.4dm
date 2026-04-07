//%attributes = {"invisible":true,"preemptive":"capable"}
// Worker_SaveStatsAsHTML (parm1; parm2; ...) : result
// 
// DESCRIPTION
//   Saves the collected stats to the file.
//   $1 can be "flame" or "profile".
//
#DECLARE($statType : Text; $filePath : Text)
// ----------------------------------------------------
ASSERT:C1129(Count parameters:C259=2)
ASSERT:C1129(($statType="flame") || ($statType="profile"); "Expecting $2 to be \"flame\" or \"profile\".")

If ($filePath="")
	return 
End if 

File_Delete($filePath)

Init_GlobalTracking

If (LogConfig_IsDebugEnabled())
	Log_INFO(Current method name:C684+" > __Global_PerfObj = "+JSON Stringify:C1217(__Global_PerfObj; *))
	Log_INFO(Current method name:C684+" > __Global_PerfFlameObj = "+JSON Stringify:C1217(__Global_PerfFlameObj; *))
End if 

If ($statType="profile")
	Performance_SaveTrackingAsHTML($statType; __Global_PerfObj; $filePath)
Else 
	Performance_SaveTrackingAsHTML($statType; __Global_PerfFlameObj; $filePath)
End if 
