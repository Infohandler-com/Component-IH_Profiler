//%attributes = {"invisible":true,"preemptive":"capable"}
// FileBuffer_EOF () : isEOF
// FileBuffer_EOF () : boolean
// 
// DESCRIPTION
//   Returns true if we are at the end of file.
//
C_BOOLEAN:C305($0; $vb_isEOF)
// ----------------------------------------------------
// HISTORY
//   Created by: DB (09/14/09)
//   Mod: DB (04/01/2012) - Used different logic
// ----------------------------------------------------

$vb_isEOF:=False:C215
If (fileBuffer_buffer="")  // Buffer must be empty
	If (fileBuffer_DocSize=Get document position:C481(fileBuffer_DocRef))  // Must be at end of file
		$vb_isEOF:=True:C214
	End if 
End if 

$0:=$vb_isEOF