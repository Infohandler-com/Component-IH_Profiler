//%attributes = {"invisible":true,"preemptive":"capable"}
// Folder_DoesExist (path to folder) : doesExist
// 
// DESCRIPTION:
//   Returns true if the folder exists
//
C_TEXT:C284($1; $Folder_vt_fullPath)  // path to folder
C_BOOLEAN:C305($0; $Folder_vb_doesExist)
// ----------------------------------------------------
// MODIFICATION HISTORY:
//   Added: DB (7/17/03 @ 15:46:39)
// ----------------------------------------------------

$Folder_vb_doesExist:=False:C215
If (Asserted:C1132(Count parameters:C259=1))
	$Folder_vt_fullPath:=$1
	
	If ($Folder_vt_fullPath#"")
		If (Test path name:C476($Folder_vt_fullPath)=Is a folder:K24:2)
			$Folder_vb_doesExist:=True:C214
		End if 
	End if 
End if   // ASSERT

$0:=$Folder_vb_doesExist