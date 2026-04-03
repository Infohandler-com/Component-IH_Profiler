//%attributes = {"invisible":true,"preemptive":"capable"}
// Worker_inWorker () boolean
// 
// DESCRIPTION
//   Returns true if the current process is the worker process.
//
#DECLARE()->$proc_in_worker_proc : Boolean
$proc_in_worker_proc:=(Process number:C372(Worker_GetProcessName)=Current process:C322)