//%attributes = {"invisible":true,"preemptive":"capable"}
//Method: Folder_ParentName
//Created by: Peter, Feb, 2000 11:30
//Called from many places including StartWindows, StartMacintosh
//Returns the Parent Name of the file pathname we pass in
//
// Last Modified by: DB (7/25/03 @ 09:28:20) - added alternate seperator
#DECLARE($HFS_FullPath : Text; $HFS_AltSeperator : Text)->$HFS_ParentName : Text

If (Asserted:C1132((Count parameters:C259>=1) & (Count parameters:C259<=2)))
	If (Count parameters:C259<2)
		$HFS_AltSeperator:=Folder separator:K24:12
	End if 
	
	var $i : Integer
	For ($i; Length:C16($HFS_FullPath); 1; -1)
		If ($HFS_FullPath[[$i]]=$HFS_AltSeperator) & ($i#Length:C16($HFS_FullPath))
			$HFS_ParentName:=Substring:C12($HFS_FullPath; 1; $i)
			$i:=0  //end loop
		End if 
	End for 
End if   // ASSERT
