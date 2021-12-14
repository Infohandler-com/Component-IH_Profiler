//%attributes = {"invisible":true,"preemptive":"capable"}
// Worker_Receive_Flame (performanceArrayObj)
// Worker_Receive_Flame (object)
// 
// DESCRIPTION
//   
//
C_OBJECT:C1216($1; $obj)
// ----------------------------------------------------
// HISTORY
//   Created by: DB (05/23/2017)
// ----------------------------------------------------

ASSERT:C1129(Count parameters:C259=1)
$obj:=$1

OnErr_Install_Handler("OnErr_GENERIC_Profiler")

Init_ThreadSafe

ARRAY TEXT:C222($at_method; 0)
ARRAY LONGINT:C221($al_minTime; 0)
ARRAY LONGINT:C221($al_maxTime; 0)
ARRAY REAL:C219($ar_totalTime; 0)
ARRAY LONGINT:C221($al_count; 0)

OnErr_ClearError
If (OB Is defined:C1231($obj; "methods"))
	OB GET ARRAY:C1229($obj; "methods"; $at_method)
	OB GET ARRAY:C1229($obj; "minTime"; $al_minTime)
	OB GET ARRAY:C1229($obj; "maxTime"; $al_maxTime)
	OB GET ARRAY:C1229($obj; "totalTime"; $ar_totalTime)
	OB GET ARRAY:C1229($obj; "count"; $al_count)
Else 
	EXECUTE METHOD:C1007("SLACK_SendWarning"; *; Current method name:C684+": encountered an issue with arrays")
	Log_ERR_CRITICAL("IH_Profiler Component Error --> "+Current method name:C684+" $obj is--> "+JSON Stringify:C1217($obj; *); "On Err Trigger")
	LogNamed_AppendToFile("On Err Trigger"; "IH_Profiler Component Error --> "+Current method name:C684+" $obj is--> "+JSON Stringify:C1217($obj; *); "On Err Trigger")
End if 

If (OnErr_GetLastError=0)
	
	C_LONGINT:C283($pos; $i)
	For ($i; 1; Size of array:C274($at_method))
		$pos:=Find in array:C230(_ML_Flame_Method; $at_method{$i})
		If ($pos<1)  // not found
			APPEND TO ARRAY:C911(_ML_Flame_Method; $at_method{$i})
			APPEND TO ARRAY:C911(_ML_Flame_minTime; $al_minTime{$i})
			APPEND TO ARRAY:C911(_ML_Flame_maxTime; $al_maxTime{$i})
			APPEND TO ARRAY:C911(_ML_Flame_totalTime; $ar_totalTime{$i})
			APPEND TO ARRAY:C911(_ML_Flame_count; $al_count{$i})
		Else 
			
			If (_ML_Flame_minTime{$pos}>$al_minTime{$i})
				_ML_Flame_minTime{$pos}:=$al_minTime{$i}
			End if 
			
			If (_ML_Flame_maxTime{$pos}<$al_maxTime{$i})
				_ML_Flame_maxTime{$pos}:=$al_maxTime{$i}
			End if 
			
			_ML_Flame_totalTime{$pos}:=_ML_Flame_totalTime{$pos}+$ar_totalTime{$i}
			_ML_Flame_count{$pos}:=_ML_Flame_count{$pos}+$al_count{$i}
		End if 
	End for 
	
Else 
	
	EXECUTE METHOD:C1007("SLACK_SendWarning"; *; Current method name:C684+": encountered an issue with arrays")
	Log_ERR_CRITICAL("IH_Profiler Component Error --> "+Current method name:C684+" $obj is--> "+JSON Stringify:C1217($obj; *); "On Err Trigger")
	LogNamed_AppendToFile("On Err Trigger"; "IH_Profiler Component Error --> "+Current method name:C684+" $obj is--> "+JSON Stringify:C1217($obj; *); "On Err Trigger")
	
End if 

OnErr_Install_Handler