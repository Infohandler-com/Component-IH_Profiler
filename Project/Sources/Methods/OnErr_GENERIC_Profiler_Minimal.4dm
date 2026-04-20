//%attributes = {"invisible":true,"preemptive":"capable"}
// OnErr_GENERIC_Profiler_Minimal ()
//
// DESCRIPTION
//   The simplest error handler. No external logging.
//
// ----------------------------------------------------
// HISTORY
//   Mod by: Dani Beaubien (9/9/13) - Enhanced the information that is coming out
//   Mod by: Dani Beaubien (2020-02-14) - Added gErrorTextArr
// ----------------------------------------------------

ARRAY TEXT:C222(gErrorTextArr; 0)
var gError : Integer
gError:=Error

var $t_alertText : Text
$t_alertText:="error "+String:C10(ERROR)
$t_alertText:=" ** ERR ** --> "+Error method+" line #"+String:C10(Error line)+"- "+$t_alertText+". Check On Err log for more detail"
APPEND TO ARRAY:C911(gErrorTextArr; $t_alertText)

ARRAY LONGINT:C221($al_err_code; 0)
ARRAY TEXT:C222($as_component; 0)
ARRAY TEXT:C222($as_error; 0)
_O_GET LAST ERROR STACK:C1015($al_err_code; $as_component; $as_error)
var $i : Integer
For ($i; 1; Size of array:C274($al_err_code))
	APPEND TO ARRAY:C911(gErrorTextArr; "     #"+String:C10($i)+"/"+String:C10(Size of array:C274($al_err_code))+" ERROR: "+String:C10($al_err_code{$i})+"; MESSAGE: \""+$as_error{$i}+"\"")
End for 
