//%attributes = {"invisible":true,"preemptive":"capable"}
// OnErr_GENERIC_Profiler ()
//
// DESCRIPTION
//   The simplest error handler. Information is sent to the log.
//
// ----------------------------------------------------
// HISTORY
//   Mod by: Dani Beaubien (9/9/13) - Enhanced the information that is coming out
//   Mod by: Dani Beaubien (2020-02-14) - Added gErrorTextArr
// ----------------------------------------------------

ARRAY TEXT:C222(gErrorTextArr; 0)
OnErr_GENERIC_Profiler_Minimal

var $i : Integer
For ($i; 1; Size of array:C274(gErrorTextArr))
	If ($i=1)
		Log_ERR_CRITICAL(gErrorTextArr{$i}+" Check On Err log for more detail.")
	End if 
	LogNamed_AppendToFile("On Err Trigger"; gErrorTextArr{$i})
End for 
