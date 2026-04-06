//%attributes = {"invisible":true,"preemptive":"capable"}
// OnErr_GetLastErrorMessages () : errorMessages
//
// DESCRIPTION
//   Returns the text of the last error encountered.
//
#DECLARE()->$last_error_messages : Text

var $i : Integer
For ($i; 1; Size of array:C274(gErrorTextArr))
	If ($i#1)
		$last_error_messages+=Char:C90(Carriage return:K15:38)
	End if 
	$last_error_messages+=gErrorTextArr{$i}
End for 
