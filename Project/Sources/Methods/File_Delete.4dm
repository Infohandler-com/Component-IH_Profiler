//%attributes = {"invisible":true,"preemptive":"capable"}
// File_Delete (path to file)
// File_Delete (text)
// 
// DESCRIPTION
//   Deletes the document pass to it.
//
#DECLARE($vt_fileName : Text)

If (File_DoesExist($vt_fileName))
	DELETE DOCUMENT:C159($vt_fileName)
End if 
