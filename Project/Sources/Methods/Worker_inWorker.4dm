//%attributes = {"invisible":true,"preemptive":"capable"}
// Worker_inWorker () boolean
// 
// DESCRIPTION
//   Returns true if the current process is the worker process.
//
C_BOOLEAN:C305($0)
// ----------------------------------------------------
// HISTORY
//   Created by: DB (05/24/2017)
// ----------------------------------------------------

$0:=(Process number:C372(Worker_GetProcessName)=Current process:C322)