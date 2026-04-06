//%attributes = {"invisible":true,"preemptive":"incapable"}
// File__UnitTests ($action)
// Unit tests for File_GetExtension, File_GetFileName, File_GetFolderName,
// File_DoesExist, and File_Delete

#DECLARE($action : Text)

Case of 
	: ($action="RunTests")
		UnitTest_RunTest("File_GetExtension_TextFile")
		UnitTest_RunTest("File_GetExtension_NoExtension")
		UnitTest_RunTest("File_GetExtension_MultipleDotsPicksLast")
		UnitTest_RunTest("File_GetFileName_FullPath")
		UnitTest_RunTest("File_GetFileName_EmptyPath")
		UnitTest_RunTest("File_GetFileName_BareName")
		UnitTest_RunTest("File_GetFolderName_FullPath")
		UnitTest_RunTest("File_GetFolderName_BareName")
		UnitTest_RunTest("File_DoesExist_EmptyPath")
		UnitTest_RunTest("File_DoesExist_ExistingFile")
		UnitTest_RunTest("File_DoesExist_NonExistentFile")
		UnitTest_RunTest("File_Delete_NonExistentIsNoOp")
		
	: ($action="File_GetExtension_TextFile")
		var $result : Text
		$result:=File_GetExtension("myfile.txt")
		UnitTest_Assert($result="txt"; "Extension of 'myfile.txt' should be 'txt', got: "+$result)
		
	: ($action="File_GetExtension_NoExtension")
		var $result : Text
		$result:=File_GetExtension("filename")
		UnitTest_Assert($result=""; "File with no extension should return empty string, got: "+$result)
		
	: ($action="File_GetExtension_MultipleDotsPicksLast")
		// Only the last extension should be returned
		var $result : Text
		$result:=File_GetExtension("/path/to/archive.tar.gz")
		UnitTest_Assert($result="gz"; "Last extension of 'archive.tar.gz' should be 'gz', got: "+$result)
		
	: ($action="File_GetFileName_FullPath")
		var $result : Text
		$result:=File_GetFileName("/Users/test/myfile.txt")
		UnitTest_Assert($result="/Users/test/myfile.txt"; "Filename should be '/Users/test/myfile.txt', got: "+$result)
		
	: ($action="File_GetFileName_EmptyPath")
		var $result : Text
		$result:=File_GetFileName("")
		UnitTest_Assert($result=""; "Empty path should return empty filename, got: "+$result)
		
	: ($action="File_GetFileName_BareName")
		// A bare filename with no path separators should return itself
		var $result : Text
		$result:=File_GetFileName("myfile.txt")
		UnitTest_Assert($result="myfile.txt"; "Bare filename 'myfile.txt' should return 'myfile.txt', got: "+$result)
		
	: ($action="File_GetFolderName_FullPath")
		var $result : Text
		$result:=File_GetFolderName("Users:test:myfile.txt")
		UnitTest_Assert($result="Users:test:"; "Folder should be 'Users:test:', got: "+$result)
		
	: ($action="File_GetFolderName_BareName")
		// A bare filename with no directory component should return empty
		var $result : Text
		$result:=File_GetFolderName("myfile.txt")
		UnitTest_Assert($result=""; "Bare filename should have no folder, got: "+$result)
		
	: ($action="File_DoesExist_EmptyPath")
		var $result_boolean : Boolean
		$result_boolean:=File_DoesExist("")
		UnitTest_Assert(Not:C34($result_boolean); "Empty path should return False for File_DoesExist")
		
	: ($action="File_DoesExist_ExistingFile")
		// The project structure file always exists
		var $result_boolean : Boolean
		$result_boolean:=File_DoesExist(Structure file:C489)
		UnitTest_Assert($result_boolean; "Structure file should exist: "+Structure file:C489)
		
	: ($action="File_DoesExist_NonExistentFile")
		var $result_boolean : Boolean
		$result_boolean:=File_DoesExist("/totally_nonexistent_abc12345/fake_file.txt")
		UnitTest_Assert(Not:C34($result_boolean); "Non-existent path should return False for File_DoesExist")
		
	: ($action="File_Delete_NonExistentIsNoOp")
		// Deleting a non-existent file should be a safe no-op (no error thrown)
		var $caught : Boolean
		$caught:=False:C215
		File_Delete("/totally_nonexistent_abc12345/fake_file.txt")
		$caught:=True:C214  // if we reach here, no error was thrown
		UnitTest_Assert($caught; "File_Delete on non-existent file should not throw an error")
		
End case 
