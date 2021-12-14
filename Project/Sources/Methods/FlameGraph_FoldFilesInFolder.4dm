//%attributes = {"invisible":true,"shared":true}
// FlameGraph_FoldFilesInFolder ({folderPath}) : numFiles
// FlameGraph_FoldFilesInFolder ({text}) : longint
// 
// DESCRIPTION
//   Takes a folder of unfolded flamegraph files created by this component
//   and combines all the results in each file into a single folded file
//   that flamegraph.pl is used to turn the folded fileds into SVGs.
//
//   If no path is provided then a select dialog will ask for a folder.
//
C_TEXT:C284($1; $vt_folderPath)  // OPTIONAL
C_LONGINT:C283($0; $vl_numFileSummarized)
// ----------------------------------------------------
// HISTORY
//   Created by: DB (05/05/2016)
// ----------------------------------------------------

$vl_numFileSummarized:=0
If (Asserted:C1132(Count parameters:C259<=1))
	If (Count parameters:C259>=1)
		$vt_folderPath:=$1
	Else 
		$vt_folderPath:=Select folder:C670("Select RAW FlameGraph folder"; File_GetFolderName(Structure file:C489(*)))
		If (OK=0)
			$vt_folderPath:=""
		End if 
	End if 
	
	
	If ($vt_folderPath#"")
		If (Folder_DoesExist($vt_folderPath))
			
			ARRAY TEXT:C222($at_fileNames; 0)
			DOCUMENT LIST:C474($vt_folderPath; $at_fileNames)
			
			C_TEXT:C284($vt_svg)
			C_LONGINT:C283($i)
			For ($i; 1; Size of array:C274($at_fileNames))
				If ($at_fileNames{$i}="@flamegraph@.txt") & ($at_fileNames{$i}#"@[SUMMARY]@")
					C_TEXT:C284($vt)
					$vt:=FlameGraph_FoldFile($vt_folderPath+$at_fileNames{$i})
					If (File_DoesExist($vt))
						$vl_numFileSummarized:=$vl_numFileSummarized+1
						
						$vt_svg:=FlameGraph_FoldedFileToSVG($vt)
					End if 
				End if 
			End for 
			
		End if 
	End if 
	
End if   // ASSERT
$0:=$vl_numFileSummarized
