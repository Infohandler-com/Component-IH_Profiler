//%attributes = {"invisible":true,"preemptive":"capable"}
// Performance_TrackCall (parm1; parm2; ...) : result
// Performance_TrackCall (parm1; parm2; ...) : result
// 
// DESCRIPTION
//   Adds the performance information onto the passed arrays.
//
#DECLARE($vt_FullLocalMethodName : Text; $vl_timeToExecute : Integer; $ap_MethodArrPtr : Pointer; $ap_minTimeArrPtr : Pointer; $ap_maxTimeArrPtr : Pointer; $ap_totalTimeArrPtr : Pointer; $ap_countArrPtr : Pointer)
ASSERT:C1129(Count parameters:C259=7)
$vt_FullLocalMethodName:=Replace string:C233($vt_FullLocalMethodName; " "; "_")

// # Add our tracking info to our local arrays
C_LONGINT:C283($pos)
$pos:=Find in array:C230($ap_MethodArrPtr->; $vt_FullLocalMethodName)
If ($pos<1)
	$pos:=Size of array:C274($ap_MethodArrPtr->)+1
	APPEND TO ARRAY:C911($ap_MethodArrPtr->; $vt_FullLocalMethodName)
	APPEND TO ARRAY:C911($ap_minTimeArrPtr->; $vl_timeToExecute)
	APPEND TO ARRAY:C911($ap_maxTimeArrPtr->; $vl_timeToExecute)
	APPEND TO ARRAY:C911($ap_totalTimeArrPtr->; $vl_timeToExecute)
	APPEND TO ARRAY:C911($ap_countArrPtr->; 1)
	
Else 
	If ($ap_minTimeArrPtr->{$pos}>$vl_timeToExecute)
		$ap_minTimeArrPtr->{$pos}:=$vl_timeToExecute
	End if 
	If ($ap_maxTimeArrPtr->{$pos}<$vl_timeToExecute)
		$ap_maxTimeArrPtr->{$pos}:=$vl_timeToExecute
	End if 
	$ap_totalTimeArrPtr->{$pos}:=$ap_totalTimeArrPtr->{$pos}+$vl_timeToExecute
	$ap_countArrPtr->{$pos}:=$ap_countArrPtr->{$pos}+1
End if 
