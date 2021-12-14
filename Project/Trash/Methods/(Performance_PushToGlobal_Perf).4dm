//%attributes = {"invisible":true,"preemptive":"capable"}
// Performance_PushToGlobal_Perf ()
// 
// DESCRIPTION
//   Sends the current performance arrays to the main
//   main worker so that the stats can be collected centrally.
//
// ----------------------------------------------------
// HISTORY
//   Created by: DB (05/23/2017)
// ----------------------------------------------------

Init_ThreadSafe

If (Size of array:C274(_ML_Perf_Method)>0)  //   Mod by: Dani Beaubien (2020-02-06) - 
	C_OBJECT:C1216($obj)
	$obj:=New object:C1471
	OB SET ARRAY:C1227($obj; "methods"; _ML_Perf_Method)
	OB SET ARRAY:C1227($obj; "minTime"; _ML_Perf_minTime)
	OB SET ARRAY:C1227($obj; "maxTime"; _ML_Perf_maxTime)
	OB SET ARRAY:C1227($obj; "totalTime"; _ML_Perf_totalTime)
	OB SET ARRAY:C1227($obj; "count"; _ML_Perf_count)
	
	CALL WORKER:C1389(Worker_GetProcessName; "Worker_Receive_Perf"; $obj)
	
Else 
	Log_ERR_CRITICAL(Current method name:C684+": called with EMPTY arrays. Investigate why (Task 6305). __incrementLevel="+String:C10(__incrementLevel))
	LogNamed_AppendToFile("On Err Trigger"; "IH_Profiler Component Error --> called with EMPTY arrays. Investigate why (Task 6305). __incrementLevel="+String:C10(__incrementLevel))
End if 