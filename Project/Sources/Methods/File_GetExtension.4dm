//%attributes = {"invisible":true,"preemptive":"capable"}
// File_GetExtension (filePath) : fileExtension
// File_GetExtension (text) : text
// 
// DESCRIPTION
//   Returns the extension from a filename
//
#DECLARE($path : Text)->$file_extension : Text

If (Asserted:C1132(Count parameters:C259=1))
	
	C_LONGINT:C283($i; $position)
	$position:=0
	For ($i; Length:C16($path); 1; -1)
		Case of 
			: ($path[[$i]]=".")
				$position:=$i
				$i:=0
				
			: ($path[[$i]]=Folder separator:K24:12) && ($i#Length:C16($path))  // end of file name
				$i:=0
		End case 
	End for 
	
	
	If ($position>0)
		$file_extension:=Substring:C12($path; $position+1)
	Else 
		$file_extension:=""  // no extension
	End if 
End if 