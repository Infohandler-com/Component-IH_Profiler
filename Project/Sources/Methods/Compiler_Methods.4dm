//%attributes = {"invisible":true}


//Init_ThreadSafe
C_BOOLEAN:C305(Init_ThreadSafe; $1)

//Profiler_STOP
C_TEXT:C284(Profiler_STOP; $1)
C_TEXT:C284(Profiler_STOP; $2)

//Profiler_START
C_TEXT:C284(Profiler_START; $1)
C_TEXT:C284(Profiler_START; $2)
C_POINTER:C301(Array_SetSize; ${2})
C_LONGINT:C283(Array_SetSize; $1)

//OnErr_GetLastError
C_LONGINT:C283(OnErr_GetLastError; $0)

//Profiler_LogCallStack
C_LONGINT:C283(Profiler_LogCallStack; $1)

//STR_GetFlameGraphNameFromStack
C_TEXT:C284(STR_GetFlameGraphNameFromStack; $0)
C_TEXT:C284(STR_GetFlameGraphNameFromStack; $1)
C_COLLECTION:C1488(STR_GetFlameGraphNameFromStack; $2)

//Performance_TrackCall
C_TEXT:C284(Performance_TrackCall; $1)
C_LONGINT:C283(Performance_TrackCall; $2)
C_POINTER:C301(Performance_TrackCall; $3)
C_POINTER:C301(Performance_TrackCall; $4)
C_POINTER:C301(Performance_TrackCall; $5)
C_POINTER:C301(Performance_TrackCall; $6)
C_POINTER:C301(Performance_TrackCall; $7)

//Profiler_LogFlameStats
C_TEXT:C284(Profiler_LogFlameStats; $1)

//Worker_GetProcessName
C_TEXT:C284(Worker_GetProcessName; $0)

//Worker_inWorker
C_BOOLEAN:C305(Worker_inWorker; $0)

//Profiler_CallStack_GetCurrent
C_TEXT:C284(Profiler_CallStack_GetCurrent; $0)

//Profiler_CallStack_GetPrevious
C_TEXT:C284(Profiler_CallStack_GetPrevious; $0)

//Profiler_GetLocalCallChainStats
C_TEXT:C284(Profiler_GetLocalCallChainStats; $0)

//Profiler_GetLocalProfileStats
C_TEXT:C284(Profiler_GetLocalProfileStats; $0)

//Profiler_SaveGlobalStatsAsHTML
C_TEXT:C284(Profiler_SaveGlobalStatsAsHTML; $1)
C_TEXT:C284(Profiler_SaveGlobalStatsAsHTML; $2)

//File_Delete
C_TEXT:C284(File_Delete; $1)

//File_DoesExist
C_BOOLEAN:C305(File_DoesExist; $0)
C_TEXT:C284(File_DoesExist; $1)

//Folder_VerifyExistance
C_TEXT:C284(Folder_VerifyExistance; $1)

//Folder_DoesExist
C_BOOLEAN:C305(Folder_DoesExist; $0)
C_TEXT:C284(Folder_DoesExist; $1)

//Folder_ParentName
C_TEXT:C284(Folder_ParentName; $0)
C_TEXT:C284(Folder_ParentName; $1)
C_TEXT:C284(Folder_ParentName; $2)

//Worker_SaveStatsAsHTML
C_TEXT:C284(Worker_SaveStatsAsHTML; $1)
C_TEXT:C284(Worker_SaveStatsAsHTML; $2)

//BuildNo_GetBuildNo_ProfileComp
C_OBJECT:C1216(BuildNo_GetBuildNo_ProfileComp; $0)

//BuildNo_SetBuildNo_ProfileComp
C_TEXT:C284(BuildNo_SetBuildNo_ProfileComp; $1)
C_TEXT:C284(BuildNo_SetBuildNo_ProfileComp; $2)
C_TEXT:C284(BuildNo_SetBuildNo_ProfileComp; $3)

//Date2String
C_TEXT:C284(Date2String; $0)
C_DATE:C307(Date2String; $1)
C_TEXT:C284(Date2String; $2)

//STR_HTML_Encode
C_TEXT:C284(STR_HTML_Encode; $0)
C_TEXT:C284(STR_HTML_Encode; $1)

//Profiler_SaveProcessStatsAsHTML
C_TEXT:C284(Profiler_SaveProcessStatsAsHTML; $1)
C_TEXT:C284(Profiler_SaveProcessStatsAsHTML; $2)

//FlameGraph_FoldedFileToSVG
C_TEXT:C284(FlameGraph_FoldedFileToSVG; $0)
C_TEXT:C284(FlameGraph_FoldedFileToSVG; $1)

//FlameGraph_FoldFile
C_TEXT:C284(FlameGraph_FoldFile; $0)
C_TEXT:C284(FlameGraph_FoldFile; $1)

//Array_ConvertFromTextDelimited
C_POINTER:C301(Array_ConvertFromTextDelimited; $1)
C_TEXT:C284(Array_ConvertFromTextDelimited; $2)
C_TEXT:C284(Array_ConvertFromTextDelimited; $3)

//File_GetFolderName
C_TEXT:C284(File_GetFolderName; $0)
C_TEXT:C284(File_GetFolderName; $1)

//File_GetFileName
C_TEXT:C284(File_GetFileName; $0)
C_TEXT:C284(File_GetFileName; $1)

//File_GetExtension
C_TEXT:C284(File_GetExtension; $0)
C_TEXT:C284(File_GetExtension; $1)

//FileBuffer_Init
C_TIME:C306(FileBuffer_Init; $1)
C_LONGINT:C283(FileBuffer_Init; $2)

//FileBuffer_FetchData_ByString
C_TEXT:C284(FileBuffer_FetchData_ByString; $0)
C_TEXT:C284(FileBuffer_FetchData_ByString; $1)
C_TEXT:C284(FileBuffer_FetchData_ByString; $2)

//FileBuffer_EOF
C_BOOLEAN:C305(FileBuffer_EOF; $0)

//FlameGraph_FoldFilesInFolder
C_LONGINT:C283(FlameGraph_FoldFilesInFolder; $0)
C_TEXT:C284(FlameGraph_FoldFilesInFolder; $1)

//OnErr_Install_Handler
C_TEXT:C284(OnErr_Install_Handler; $1)

//OnErr_GetLastErrorMessages
C_TEXT:C284(OnErr_GetLastErrorMessages; $0)

//Performance_UpdateTrackingObj
C_OBJECT:C1216(Performance_UpdateTrackingObj; $1)
C_TEXT:C284(Performance_UpdateTrackingObj; $2)
C_LONGINT:C283(Performance_UpdateTrackingObj; $3)

//Worker_UpdateGlobalTrackingInfo
C_OBJECT:C1216(Worker_UpdateGlobalTrackingInfo; $1)
C_OBJECT:C1216(Worker_UpdateGlobalTrackingInfo; $2)

//Init_GlobalTracking
C_BOOLEAN:C305(Init_GlobalTracking; $1)

//Performance_Global_AddTrackObj
C_OBJECT:C1216(Performance_Global_AddTrackObj; $1)
C_OBJECT:C1216(Performance_Global_AddTrackObj; $2)

//Performance_SaveTrackingAsHTML
C_TEXT:C284(Performance_SaveTrackingAsHTML; $1)
C_OBJECT:C1216(Performance_SaveTrackingAsHTML; $2)
C_TEXT:C284(Performance_SaveTrackingAsHTML; $3)

//Performance_GetTrackingAsTSV
C_TEXT:C284(Performance_GetTrackingAsTSV; $0)
C_TEXT:C284(Performance_GetTrackingAsTSV; $1)
C_OBJECT:C1216(Performance_GetTrackingAsTSV; $2)