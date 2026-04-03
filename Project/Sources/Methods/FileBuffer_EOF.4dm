//%attributes = {"invisible":true,"preemptive":"capable"}
// FileBuffer_EOF () : isEOF
// FileBuffer_EOF () : boolean
// 
// DESCRIPTION
//   Returns true if we are at the end of file.
//
#DECLARE()->$vb_isEOF : Boolean

If (fileBuffer_buffer="")  // Buffer must be empty
	If (fileBuffer_DocSize=Get document position:C481(fileBuffer_DocRef))  // Must be at end of file
		$vb_isEOF:=True:C214
	End if 
End if 
