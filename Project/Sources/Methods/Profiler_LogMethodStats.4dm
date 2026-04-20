//%attributes = {"invisible":true,"shared":true,"preemptive":"capable"}
// Profiler_LogMethodStats ()
// 
// DESCRIPTION
//   This method dumps to the log file the collected method stats
//   of the current process' profile arrays.
//
//   Dumps Columns: Method Name, Call Count, Min, Avg, Max Total
//
Init_ThreadSafe

// If running in the worker, then want the info to go to a different file.
var $vt_namedLogFile : Text
$vt_namedLogFile:="Profiler Method Stats"
If (Worker_inWorker)
	$vt_namedLogFile:=$vt_namedLogFile+" GLOBAL"
End if 

var $vt_buffer : Text
$vt_buffer:=Profiler_GetLocalProfileStats

If ($vt_buffer#"")
	Log_WARN("  **** Method profile statistics records saved directly to the \""+$vt_namedLogFile+"\" Log file"; $vt_namedLogFile)
	LogNamed_AppendToFile($vt_namedLogFile; $vt_buffer)  //;"noProc#";"noTimeStamp";"beQuiet")
End if 