//%attributes = {}

Profiler_SaveGlobalStatsAsHTML

If (Process number:C372("Log_AppLog")<1)
	Log_OpenDisplayWindow
End if 
FileBuffer_Init()
Log_SetUserNameForProcess("dbeaubien")
UnitTest__Stopwatch()
C_TEXT:C284($folder)
$folder:=Folder_ParentName(Folder_ParentName(Structure file:C489))+"IH_Profiler Tests"+Folder separator:K24:12
Folder_VerifyExistance($folder)

// TEST #1
If (True:C214)
	Profiler_START("test 1")
	If (True:C214)
		Profiler_START("test 2")
		If (True:C214)
			C_LONGINT:C283($i)
			For ($i; 1; 10)
				Profiler_START("test3")
				DELAY PROCESS:C323(Current process:C322; 1)
				Profiler_STOP("test3")
				
				DELAY PROCESS:C323(Current process:C322; 1)
			End for 
			Profiler_LogCallStack
		End if 
		Profiler_STOP("test 2")
		
		For ($i; 1; 10)
			Profiler_START("test3")
			DELAY PROCESS:C323(Current process:C322; 4)
			Profiler_STOP("test3")
			
			DELAY PROCESS:C323(Current process:C322; 1)
		End for 
		
		DELAY PROCESS:C323(Current process:C322; 1)
	End if 
	Profiler_STOP("test 1")
	
	// Log what has been done in just this process
	Profiler_SaveProcessStatsAsHTML("profile"; $folder+"Test 1 - Profile.html")
	Profiler_SaveProcessStatsAsHTML("flame"; $folder+"Test 1 - Flame.html")
	Profiler_LogMethodStats
	Profiler_LogCallChainStats
	Profiler_LogFlameStats("Local Process 1")  // Save current process stats to "FlameGraph Unfolded - Local Process Log.txt"
End if 


// New Round of profiling
If (True:C214)
	Profiler_START("test1")
	Profiler_START("test3")
	DELAY PROCESS:C323(Current process:C322; 1)
	Profiler_STOP("test3")
	Profiler_STOP("test1")
	Profiler_LogFlameStats("Local Process 2")  // Save current process stats to "FlameGraph Unfolded - Local Process Log.txt"
	
	// Log what has been done in just this process
	Profiler_SaveProcessStatsAsHTML("profile"; $folder+"Test 2 - Profile.html")
	Profiler_SaveProcessStatsAsHTML("flame"; $folder+"Test 2 - Flame.html")
	Profiler_LogMethodStats
	Profiler_LogCallChainStats
	Profiler_LogFlameStats("ProfilerStats")  //   Mod: DB (05/03/2016)
End if 

// Dump globally
Profiler_SaveGlobalStatsAsHTML("profile"; $folder+"Global Results - Profile.html")
Profiler_SaveGlobalStatsAsHTML("flame"; $folder+"Global Results - Flame.html")
Profiler_ClearGlobalStats  // Dumps global stats and clears all global data

ALERT:C41("done")
SHOW ON DISK:C922($folder; *)
Log_FlushCache  // Forces all the logs to disk
