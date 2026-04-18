//%attributes = {"invisible":true,"preemptive":"capable"}
// Method: FileBuffer_Init (docRef {; buffer size})
// Method: FileBuffer_Init (time {; longint})
// ===============================================================
// ---- PARAMETERS AND RESULTS ----
//   $1 [in]: reference to an already open document
//   $2 [optional in]: byte size to set the buffer to be
//   no return result
// ---- DESCRIPTION ----
//   This method, initalizes the necessary vars and pre-fills the buffer.
// ---- CHANGE HISTORY ----
//   2000/02/28   DB   Created
// ===============================================================

#DECLARE($fileBuffer_DocRef : Time; $fileBuffer_MaxSize : Integer)
var fileBuffer_DocRef : Time
fileBuffer_DocRef:=$fileBuffer_DocRef

var fileBuffer_MaxSize : Integer
fileBuffer_MaxSize:=$fileBuffer_MaxSize

var fileBuffer_buffer : Text

// set the max size of the buffer
If (fileBuffer_MaxSize<=0)
	fileBuffer_MaxSize:=10240  // default to buffer to 10k
End if 

// record the size of the document
var fileBuffer_DocSize; fileBuffer_curPos : Integer
fileBuffer_DocSize:=Get document size:C479(fileBuffer_DocRef)
fileBuffer_curPos:=1

// load some data
fileBuffer_buffer:=""
FileBuffer_FillBuffer