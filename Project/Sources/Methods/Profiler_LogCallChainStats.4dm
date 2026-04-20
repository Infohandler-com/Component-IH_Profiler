//%attributes = {"invisible":true,"shared":true,"preemptive":"capable"}
// Profiler_LogCallChainStats ()
// 
// DESCRIPTION
//   This method dumps to the log file the current process'; collected method call chain
//   stats of the profile arrays.
//
//   Dumps Columns: Call Chain, Call Count, Min, Avg, Max Total
//
Init_ThreadSafe

// If running in the worker, then want the info to go to a different file.
var $vt_namedLogFile : Text
$vt_namedLogFile:="Profiler Call Chain Stats"
If (Worker_inWorker)
	$vt_namedLogFile+=" GLOBAL"
End if 

var $vt_buffer : Text
$vt_buffer:=Profiler_GetLocalCallChainStats

If ($vt_buffer#"")
	Log_WARN("  **** Method profile flame statistics saved directly to the \""+$vt_namedLogFile+"\" log file"; $vt_namedLogFile)
	LogNamed_AppendToFile($vt_namedLogFile; $vt_buffer)  //;"noProc#";"noTimeStamp";"beQuiet")
End if 
