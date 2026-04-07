//%attributes = {"invisible":true,"preemptive":"capable"}
// File_DoesExist (path to file) : does exist
// File_DoesExist (text) : boolean
// 
// DESCRIPTION:
//   Returns true if the file exists. It will create any directories if
//   are missing.
//
#DECLARE($File_vt_fullPath : Text)->$File_vb_doesExist : Boolean

If (Asserted:C1132(Count parameters:C259=1))
	
	If ($File_vt_fullPath#"")
		// make sure that the directory exists that this file is supposed to be in
		Folder_VerifyExistance(Folder_ParentName($File_vt_fullPath))
		
		If (Test path name:C476($File_vt_fullPath)=Is a document:K24:1)
			$File_vb_doesExist:=True:C214
		End if 
	End if 
End if   // ASSERT
