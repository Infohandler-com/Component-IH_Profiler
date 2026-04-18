//%attributes = {"invisible":true,"shared":true}
// FlameGraph_FoldedFileToSVG (foldedFilePath) : svgFilePath
// FlameGraph_FoldedFileToSVG (text) : text
// 
// DESCRIPTION
//   Creates a flamegraph svg based on the folded file.
//
//   NOTE: This uses Brendan Gregg's flamegraph.pl perl script.
//   https://github.com/brendangregg/FlameGraph
//
#DECLARE($foldedFilePath : Text)->$svgFilePath : Text

If (Asserted:C1132(Count parameters:C259=1))
	
	var $vt_pathToPerlScript : Text
	$vt_pathToPerlScript:=Get 4D folder:C485(Current resources folder:K5:16)+"flamegraph.pl"
	
	If (Test path name:C476($foldedFilePath)=Is a document:K24:1) & (Test path name:C476($vt_pathToPerlScript)=Is a document:K24:1)
		var $perlScript : Text
		$perlScript:=Convert path system to POSIX:C1106($vt_pathToPerlScript)
		
		var $posixFoldedFilePath : Text
		$posixFoldedFilePath:=Convert path system to POSIX:C1106($foldedFilePath)
		
		var $in; $out; $err : Blob
		var $codeToExecute : Text
		$codeToExecute:="perl \""+$perlScript+"\" --countname=MSx10 \""+$posixFoldedFilePath+"\""
		LAUNCH EXTERNAL PROCESS:C811($codeToExecute; $in; $out; $err)
		
		// Look at the output & error 
		var $outText; $errText : Text
		$outText:=Convert to text:C1012($out; "utf-8")
		$outText:=Substring:C12($outText; 1; Length:C16($outText)-1)  //strip terminator
		$errText:=Convert to text:C1012($err; "utf-8")
		$errText:=Substring:C12($errText; 1; Length:C16($errText)-1)  //strip terminator
		
		// save the SVG
		If (BLOB size:C605($out)>0)
			$svgFilePath:=$foldedFilePath+".svg"
			File_Delete($svgFilePath)
			BLOB TO DOCUMENT:C526($svgFilePath; $out)
		End if 
	End if 
	
End if   // ASSERT
