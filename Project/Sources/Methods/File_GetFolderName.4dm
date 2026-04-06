//%attributes = {"invisible":true,"preemptive":"capable"}
// File_GetFolderName (filePath) : folderName
// File_GetFolderName (text) : text
// 
// DESCRIPTION
//   Given the path to a document, returns the path
//   to the folder the document is in.
//
#DECLARE($vt_docPath : Text)->$vt_folderPath : Text

If (Asserted:C1132(Count parameters:C259=1))
	
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
