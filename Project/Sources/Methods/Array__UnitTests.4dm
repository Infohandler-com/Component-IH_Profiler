//%attributes = {"invisible":true,"preemptive":"incapable"}
// Array__UnitTests ($action)
// Unit tests for Array_SetSize and Array_ConvertFromTextDelimited

#DECLARE($action : Text)

Case of 
	: ($action="RunTests")
		UnitTest_RunTest("Array_SetSize_Grows")
		UnitTest_RunTest("Array_SetSize_Shrinks")
		UnitTest_RunTest("Array_SetSize_NegativeClampedToZero")
		UnitTest_RunTest("Array_SetSize_SameSize")
		UnitTest_RunTest("Array_ConvertFromTextDelimited_CommaDefault")
		UnitTest_RunTest("Array_ConvertFromTextDelimited_CustomDelimiter")
		UnitTest_RunTest("Array_ConvertFromTextDelimited_EmptyInput")
		UnitTest_RunTest("Array_ConvertFromTextDelimited_SingleItem")
		UnitTest_RunTest("Array_ConvertFromTextDelimited_TrailingDelimiter")
		UnitTest_RunTest("Array_ConvertFromTextDelimited_ClearsExistingArray")
		
	: ($action="Array_SetSize_Grows")
		ARRAY TEXT:C222($at_test; 0)
		Array_SetSize(5; ->$at_test)
		UnitTest_Assert(Size of array:C274($at_test)=5; "Array should have 5 elements after growing from 0 to 5")
		
	: ($action="Array_SetSize_Shrinks")
		ARRAY TEXT:C222($at_test; 10)
		Array_SetSize(3; ->$at_test)
		UnitTest_Assert(Size of array:C274($at_test)=3; "Array should have 3 elements after shrinking from 10 to 3")
		
	: ($action="Array_SetSize_NegativeClampedToZero")
		ARRAY TEXT:C222($at_test; 5)
		Array_SetSize(-3; ->$at_test)
		UnitTest_Assert(Size of array:C274($at_test)=0; "Negative size should be clamped to 0 elements")
		
	: ($action="Array_SetSize_SameSize")
		ARRAY TEXT:C222($at_test; 5)
		$at_test{1}:="sentinel"
		Array_SetSize(5; ->$at_test)
		UnitTest_Assert(Size of array:C274($at_test)=5; "Array size should be unchanged when already at target size")
		UnitTest_Assert($at_test{1}="sentinel"; "Existing values should be preserved when size is unchanged")
		
	: ($action="Array_ConvertFromTextDelimited_CommaDefault")
		ARRAY TEXT:C222($at_test; 0)
		Array_ConvertFromTextDelimited(->$at_test; "a,b,c")
		UnitTest_Assert(Size of array:C274($at_test)=3; "Comma-delimited 'a,b,c' should produce 3 elements")
		UnitTest_Assert($at_test{1}="a"; "First element of 'a,b,c' should be 'a'")
		UnitTest_Assert($at_test{2}="b"; "Second element of 'a,b,c' should be 'b'")
		UnitTest_Assert($at_test{3}="c"; "Third element of 'a,b,c' should be 'c'")
		
	: ($action="Array_ConvertFromTextDelimited_CustomDelimiter")
		ARRAY TEXT:C222($at_test; 0)
		Array_ConvertFromTextDelimited(->$at_test; "x|y|z"; "|")
		UnitTest_Assert(Size of array:C274($at_test)=3; "Pipe-delimited 'x|y|z' should produce 3 elements")
		UnitTest_Assert($at_test{1}="x"; "First element of 'x|y|z' should be 'x'")
		UnitTest_Assert($at_test{2}="y"; "Second element of 'x|y|z' should be 'y'")
		UnitTest_Assert($at_test{3}="z"; "Third element of 'x|y|z' should be 'z'")
		
	: ($action="Array_ConvertFromTextDelimited_EmptyInput")
		ARRAY TEXT:C222($at_test; 0)
		Array_ConvertFromTextDelimited(->$at_test; "")
		UnitTest_Assert(Size of array:C274($at_test)=0; "Empty input should produce empty array")
		
	: ($action="Array_ConvertFromTextDelimited_SingleItem")
		ARRAY TEXT:C222($at_test; 0)
		Array_ConvertFromTextDelimited(->$at_test; "hello")
		UnitTest_Assert(Size of array:C274($at_test)=1; "Single item with no delimiter should produce 1-element array")
		UnitTest_Assert($at_test{1}="hello"; "The single item should be 'hello'")
		
	: ($action="Array_ConvertFromTextDelimited_TrailingDelimiter")
		ARRAY TEXT:C222($at_test; 0)
		Array_ConvertFromTextDelimited(->$at_test; "a,b,")
		UnitTest_Assert(Size of array:C274($at_test)=3; "Trailing delimiter 'a,b,' should produce 3 elements (last is empty)")
		UnitTest_Assert($at_test{1}="a"; "First element of 'a,b,' should be 'a'")
		UnitTest_Assert($at_test{2}="b"; "Second element of 'a,b,' should be 'b'")
		UnitTest_Assert($at_test{3}=""; "Third element after trailing delimiter should be empty")
		
	: ($action="Array_ConvertFromTextDelimited_ClearsExistingArray")
		ARRAY TEXT:C222($at_test; 5)
		$at_test{1}:="old"
		Array_ConvertFromTextDelimited(->$at_test; "new1,new2")
		UnitTest_Assert(Size of array:C274($at_test)=2; "Existing array should be cleared and replaced with 2 new elements")
		UnitTest_Assert($at_test{1}="new1"; "First element after clearing should be 'new1'")
		
End case 
