//%attributes = {"invisible":true,"shared":true,"preemptive":"capable"}
// Profiler_LogCallChainStats ()
// 
// DESCRIPTION
//   This method dumps to the log file the current process'; collected method call chain
//   stats of the profile arrays.
//
//   Dumps Columns: Call Chain, Call Count, Min, Avg, Max Total
//
If (False:C215)
	// ----------------------------------------------------
	// HISTORY
	//   Created by: DB (10/29/10)
	//   Mod: DB (05/22/2017) - Moved to v16 component
	// ----------------------------------------------------
End if 

Init_ThreadSafe

// If running in the worker, then want the info to go to a different file.
C_TEXT:C284($vt_namedLogFile)
$vt_namedLogFile:="Profiler Call Chain Stats"
If (Worker_inWorker)
	$vt_namedLogFile:=$vt_namedLogFile+" GLOBAL"
End if 

C_TEXT:C284($vt_buffer)
$vt_buffer:=Profiler_GetLocalCallChainStats

If ($vt_buffer#"")
	Log_WARN("  **** Method profile flame statistics saved directly to the \""+$vt_namedLogFile+"\" log file"; $vt_namedLogFile)
	LogNamed_AppendToFile($vt_namedLogFile; $vt_buffer)  //;"noProc#";"noTimeStamp";"beQuiet")
End if 
