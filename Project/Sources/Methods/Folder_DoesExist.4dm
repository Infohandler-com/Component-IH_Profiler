//%attributes = {"invisible":true,"preemptive":"capable"}
// Folder_DoesExist (path to folder) : doesExist
// 
// DESCRIPTION:
//   Returns true if the folder exists
//
#DECLARE($Folder_vt_fullPath : Text)->$Folder_vb_doesExist : Boolean

If (Asserted:C1132(Count parameters:C259=1))
	
	If ($Folder_vt_fullPath#"")
		If (Test path name:C476($Folder_vt_fullPath)=Is a folder:K24:2)
			$Folder_vb_doesExist:=True:C214
		End if 
	End if 
End if   // ASSERT
