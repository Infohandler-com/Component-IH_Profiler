//%attributes = {"invisible":true,"preemptive":"capable"}
// File_GetExtension (filePath) : fileExtension
// File_GetExtension (text) : text
// 
// DESCRIPTION
//   Returns the extension from a filename
//
C_TEXT:C284($1; $path)
C_TEXT:C284($0)
// ----------------------------------------------------
// HISTORY
//   Created by:  Rob Liveau (nuggers)
//   Mod: DB (11/20/07) - pay attention to the folder seperator
// ----------------------------------------------------

If (Asserted:C1132(Count parameters:C259=1))
	$path:=$1
	
	C_LONGINT:C283($i; $position)
	$position:=0
	For ($i; Length:C16($path); 1; -1)
		Case of 
			: ($path[[$i]]=".")
				$position:=$i
				$i:=0
				
			: ($path[[$i]]=Folder separator:K24:12) & ($i#Length:C16($path))  // end of file name
				$i:=0
		End case 
	End for 
	
	
	If ($position>0)
		$0:=Substring:C12($path; $position+1)
	Else 
		$0:=""  // no extension
	End if 
End if 