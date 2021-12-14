//%attributes = {"invisible":true,"preemptive":"capable"}
// File_GetFolderName (filePath) : folderName
// File_GetFolderName (text) : text
// 
// DESCRIPTION
//   Given the path to a document, returns the path
//   to the folder the document is in.
//
C_TEXT:C284($1; $vt_docPath)  //   Full path to document
C_TEXT:C284($0; $vt_folderPath)  //   Path to folder document is in
//
// ----------------------------------------------------
// HISTORY
//   Created by: Jeremy Sullivan (10/16/2001)
//   Mod: DB (11/20/07) - Improved and simplified
//   Mod: DB (09/18/2012) - Fixed some bugs (added Unit Tests as well)
//   Mod by: Dani Beaubien (01/22/2016) - Rewrote
// ----------------------------------------------------

$vt_folderPath:=""
If (Asserted:C1132(Count parameters:C259=1))
	$vt_docPath:=$1
	
	If ($vt_docPath=("@"+Folder separator:K24:12))
		$vt_docPath:=Substring:C12($vt_docPath; 1; Length:C16($vt_docPath)-Length:C16(Folder separator:K24:12))
	End if 
	
	Case of 
		: ($vt_docPath="")
			$vt_folderPath:=""
			
		Else 
			ARRAY TEXT:C222($at_segments; 0)
			Array_ConvertFromTextDelimited(->$at_segments; $vt_docPath; Folder separator:K24:12)
			If (Size of array:C274($at_segments)=1)
				$vt_folderPath:=""  // $at_segments{1}
			Else 
				$vt_folderPath:=Substring:C12($vt_docPath; 1; Length:C16($vt_docPath)-Length:C16($at_segments{Size of array:C274($at_segments)}))
			End if 
	End case 
	
End if   // ASSERT
$0:=$vt_folderPath
