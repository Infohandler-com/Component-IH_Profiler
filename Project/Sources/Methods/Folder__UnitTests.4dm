//%attributes = {"invisible":true,"preemptive":"incapable"}
// Folder__UnitTests ($action)
// Unit tests for Folder_DoesExist, Folder_ParentName, and Folder_VerifyExistance

#DECLARE($action : Text)

var $result : Text
var $folderPath : Text
var $result_boolean : Boolean
Case of 
	: ($action="RunTests")
		UnitTest_RunTest("Folder_DoesExist_EmptyPath")
		UnitTest_RunTest("Folder_DoesExist_ExistingFolder")
		UnitTest_RunTest("Folder_DoesExist_NonExistentFolder")
		UnitTest_RunTest("Folder_ParentName_StandardPath")
		UnitTest_RunTest("Folder_ParentName_FilePath")
		UnitTest_RunTest("Folder_ParentName_RootLevelFile")
		UnitTest_RunTest("Folder_ParentName_BareName")
		UnitTest_RunTest("Folder_VerifyExistance_ExistingFolderIsNoOp")
		
	: ($action="Folder_DoesExist_EmptyPath")
		$result_boolean:=Folder_DoesExist("")
		UnitTest_Assert(Not:C34($result_boolean); "Empty path should return False for Folder_DoesExist")
		
	: ($action="Folder_DoesExist_ExistingFolder")
		// The folder containing the structure file always exists
		$folderPath:=Folder_ParentName(Structure file:C489)
		$result_boolean:=Folder_DoesExist($folderPath)
		UnitTest_Assert($result_boolean; "Project folder should exist: "+$folderPath)
		
	: ($action="Folder_DoesExist_NonExistentFolder")
		$result_boolean:=Folder_DoesExist("/totally_nonexistent_abc12345/fake_folder/")
		UnitTest_Assert(Not:C34($result_boolean); "Non-existent folder path should return False")
		
	: ($action="Folder_ParentName_StandardPath")
		// "/Users/test/" -> "/Users/"
		$result:=Folder_ParentName("Users:test:")
		UnitTest_Assert($result="Users:"; "Parent should be 'Users:', got: "+$result)
		
	: ($action="Folder_ParentName_FilePath")
		// "/Users/test/file.txt" -> "/Users/test/"
		$result:=Folder_ParentName("Users:test:file.txt")
		UnitTest_Assert($result="Users:test:"; "Parent ofshould be 'Users:test:', got: "+$result)
		
	: ($action="Folder_ParentName_RootLevelFile")
		// "/file.txt" -> "/"
		$result:=Folder_ParentName(":file.txt")
		UnitTest_Assert($result=":"; "Parent should be ':', got: "+$result)
		
	: ($action="Folder_ParentName_BareName")
		// "filename" (no separator) -> "" (no parent)
		$result:=Folder_ParentName("filename")
		UnitTest_Assert($result=""; "Bare filename with no separator should have empty parent, got: "+$result)
		
	: ($action="Folder_VerifyExistance_ExistingFolderIsNoOp")
		// Calling VerifyExistance on a folder that exists should be a no-op
		$folderPath:=Folder_ParentName(Structure file:C489)
		Folder_VerifyExistance($folderPath)
		// After calling on an existing folder, the folder should still exist
		UnitTest_Assert(Folder_DoesExist($folderPath); "Folder should still exist after VerifyExistance: "+$folderPath)
		
End case 
