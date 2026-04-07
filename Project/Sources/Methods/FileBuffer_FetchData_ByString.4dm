//%attributes = {"invisible":true,"preemptive":"capable"}
// Method: FileBuffer_FetchData_ByString ( text to match on {;text2}) : result
#DECLARE($matchOnText : Text; $matchOnText2 : Text)->$tmpTxt : Text
var $pos; $pos2 : Integer

If (Asserted:C1132(Length:C16($matchOnText)>0))  // String being passed to search for is empty.
	
	// where is it in the string?
	$pos:=Position:C15($matchOnText; fileBuffer_buffer; *)
	If ($matchOnText2#"")
		$pos2:=Position:C15($matchOnText2; fileBuffer_buffer; *)
	End if 
	
	If ($pos<1) & ($pos2<1)  // top off the buffer and try to find it again
		FileBuffer_FillBuffer
		$pos:=Position:C15($matchOnText; fileBuffer_buffer; *)
		If ($matchOnText2#"")
			$pos2:=Position:C15($matchOnText2; fileBuffer_buffer; *)
		End if 
	End if 
	
	If ($pos2=0)  // if nothing then force to the end
		$pos2:=Length:C16(fileBuffer_buffer)+1
	End if 
	
	If ($pos=0)  // if nothing then force to the end
		$pos:=Length:C16(fileBuffer_buffer)+1
	End if 
	
	If ($pos2<$pos)  // if 2nd parm was found first then use that one
		$pos:=$pos2
		$matchOnText:=$matchOnText2
	End if 
	
	// text found, return all data PLUS the found text
	If ($pos>0)
		$pos:=$pos+(Length:C16($matchOnText)-1)
		$tmpTxt:=Substring:C12(fileBuffer_buffer; 1; $pos)
		fileBuffer_buffer:=Substring:C12(fileBuffer_buffer; $pos+1)  // advance to next char
		
	Else 
		// If buffer is less than the full size which means that we are at the
		// end of the file. Did not find the text we are looking for so
		// return all that is left  
		If (fileBuffer_MaxSize>Length:C16(fileBuffer_buffer))
			$tmpTxt:=fileBuffer_buffer
			fileBuffer_buffer:=""
		End if 
	End if 
	
	// Increment our current position in the file
	C_LONGINT:C283(fileBuffer_curPos)
	C_BLOB:C604($vx_tmpBuffer)
	TEXT TO BLOB:C554($tmpTxt; $vx_tmpBuffer; UTF8 text without length:K22:17)
	fileBuffer_curPos:=fileBuffer_curPos+BLOB size:C605($vx_tmpBuffer)
End if   // ASSERT
