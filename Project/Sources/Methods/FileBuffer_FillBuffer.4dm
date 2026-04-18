//%attributes = {"invisible":true,"preemptive":"capable"}
// Method: FileBuffer_FillBuffer

// Gets as much data as is possible so that the buffer is full

var $tmpTxt : Text
var $dataSize : Integer
$dataSize:=fileBuffer_MaxSize-Length:C16(fileBuffer_buffer)

If ($dataSize>0)  // if there is room in the buffer
	RECEIVE PACKET:C104(fileBuffer_DocRef; $tmpTxt; $dataSize)
	fileBuffer_buffer+=$tmpTxt
End if 