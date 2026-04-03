//%attributes = {"invisible":true,"shared":true,"preemptive":"capable"}
// FlameGraph_FoldFile ({srcFilePath}) : foldedFilePath
// FlameGraph_FoldFile (text) : text
// 
// DESCRIPTION
//   Takes a raw flame graph file created by this component
//   and folds all the results in the file into a a form that
//   the "FlameGraph_FoldedFileToSVG" method can then turn into a svg.
//
//   If no path is provided then a select dialog will ask for a doc.
//
//   NOTE: See Brendan Gregg's flamegraph perl scripts for more detail.
//   https://github.com/brendangregg/FlameGraph
//
#DECLARE($vt_srcFilePath : Text)->$foldedFilePath : Text

If (Asserted:C1132(Count parameters:C259<=1))
	If (Count parameters:C259<1)
		$vt_srcFilePath:=Select document:C905(File_GetFolderName(Structure file:C489(*)); ""; "Select RAW FlameGraph file"; 0)
		If (OK=1)
			$vt_srcFilePath:=Document
		Else 
			$vt_srcFilePath:=""
		End if 
	End if 
	
	
	If ($vt_srcFilePath#"")
		If (File_DoesExist($vt_srcFilePath))
			
			ARRAY TEXT:C222($at_label; 0)
			ARRAY REAL:C219($ar_time; 0)
			
			
			// # open the file and start importing the data
			C_TIME:C306($docRef)
			$docRef:=Open document:C264($vt_srcFilePath; ""; Read mode:K24:5)
			If (OK=1)
				FileBuffer_Init($docRef)
				
				C_TEXT:C284($vt_oneLine)
				Repeat 
					$vt_oneLine:=FileBuffer_FetchData_ByString(Char:C90(Carriage return:K15:38); Char:C90(Line feed:K15:40))
					$vt_oneLine:=Replace string:C233($vt_oneLine; Char:C90(Carriage return:K15:38); "")
					$vt_oneLine:=Replace string:C233($vt_oneLine; Char:C90(Line feed:K15:40); "")
					
					If ($vt_oneLine#"")
						// need to figure out where the "last" space is on the line
						C_LONGINT:C283($vl_locationOfSpace; $i)
						$vl_locationOfSpace:=0
						For ($i; Length:C16($vt_oneLine); 1; -1)
							If ($vt_oneLine[[$i]]=" ")
								$vl_locationOfSpace:=$i
								$i:=0
							End if 
						End for 
						
						If ($vl_locationOfSpace>0)
							C_TEXT:C284($vt_label)
							C_REAL:C285($vr_count)
							$vt_label:=Substring:C12($vt_oneLine; 1; $vl_locationOfSpace-1)
							$vr_count:=Num:C11(Substring:C12($vt_oneLine; $vl_locationOfSpace+1))
							
							C_LONGINT:C283($pos)
							$pos:=Find in array:C230($at_label; $vt_label)
							If ($pos>0)
								$ar_time{$pos}:=$ar_time{$pos}+$vr_count
							Else 
								APPEND TO ARRAY:C911($at_label; $vt_label)
								APPEND TO ARRAY:C911($ar_time; $vr_count)
							End if 
							
						End if 
					End if 
				Until (FileBuffer_EOF)
				CLOSE DOCUMENT:C267($docRef)
				
				
				// Determine what our "folded" file name is
				C_TEXT:C284($vt_fileExtn; $vt_fileName)
				$foldedFilePath:=File_GetFolderName($vt_srcFilePath)
				$vt_fileName:=File_GetFileName($vt_srcFilePath)
				$vt_fileExtn:=File_GetExtension($vt_fileName)
				If ($vt_fileExtn="")
					$foldedFilePath:=$vt_srcFilePath+" [FOLDED]"
				Else 
					$vt_fileName:=Substring:C12($vt_fileName; 1; Length:C16($vt_fileName)-Length:C16($vt_fileExtn)-1)  // remove the extn
					$vt_fileName:=$vt_fileName+" [FOLDED]."+$vt_fileExtn
					$foldedFilePath:=$foldedFilePath+$vt_fileName
				End if 
				
				// Create it and output the results
				File_Delete($foldedFilePath)
				$docRef:=Create document:C266($foldedFilePath)
				If (OK=1)
					SORT ARRAY:C229($at_label; $ar_time; >)
					If (Size of array:C274($at_label)>0)
						For ($i; 1; Size of array:C274($at_label))
							SEND PACKET:C103($docRef; $at_label{$i}+" "+String:C10($ar_time{$i})+Char:C90(Line feed:K15:40))
						End for 
						CLOSE DOCUMENT:C267($docRef)
					End if 
				End if 
				
				
			End if 
			
		Else 
			ALERT:C41("File not found!\r\r"+$vt_srcFilePath)
		End if 
	End if 
	
End if   // ASSERT
