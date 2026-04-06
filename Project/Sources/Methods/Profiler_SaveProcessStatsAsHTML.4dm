//%attributes = {"invisible":true,"shared":true}
// Profiler_SaveProcessStatsAsHTML (statType; filePath) 
// Profiler_SaveProcessStatsAsHTML (text; text) 
// 
// DESCRIPTION
//   Saves the collected stats for the current processes to the file.
//   $1 can be "flame" or "profile".
//
#DECLARE($statType : Text; $filePath : Text)
If (Asserted:C1132(Count parameters:C259=2))
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