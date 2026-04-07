//%attributes = {"invisible":true,"preemptive":"capable"}
// File_GetFileName (filePath) : filename
// File_GetFileName (text) : text
//
// DESCRIPTION
//   Given the path to a document, returns the document itself.
//
#DECLARE($vt_docPath : Text)->$vt_document : Text

If (Asserted:C1132(Count parameters:C259=1))
	
	Case of 
		: ($vt_docPath="")
			$vt_document:=""
			
		: ($vt_docPath=(Folder separator:K24:12+"@"))
			$vt_document:=""
			
		Else 
			ARRAY TEXT:C222($at_segments; 0)
			Array_ConvertFromTextDelimited(->$at_segments; $vt_docPath; Folder separator:K24:12)
			If (Size of array:C274($at_segments)=1)
				$vt_document:=$at_segments{1}
			Else 
				$vt_document:=Substring:C12($vt_docPath; 1+Length:C16($vt_docPath)-Length:C16($at_segments{Size of array:C274($at_segments)}))
			End if 
	End case 
	
End if   // ASSERT
