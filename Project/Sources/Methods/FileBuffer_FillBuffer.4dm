//%attributes = {"invisible":true,"preemptive":"capable"}
// Method: FileBuffer_FillBuffer

// Gets as much data as is possible so that the buffer is full

C_TEXT:C284($tmpTxt)
C_LONGINT:C283($dataSize)
$dataSize:=fileBuffer_MaxSize-Length:C16(fileBuffer_buffer)

If ($dataSize>0)  // if there is room in the buffer
	RECEIVE PACKET:C104(fileBuffer_DocRef; $tmpTxt; $dataSize)
	fileBuffer_buffer+=$tmpTxt
End if 