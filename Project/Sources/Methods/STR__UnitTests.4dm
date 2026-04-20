//%attributes = {"invisible":true,"preemptive":"incapable"}
// STR__UnitTests ($action)
// Unit tests for STR_HTML_Encode and STR_GetFlameGraphNameFromStack

#DECLARE($action : Text)

var $stack : Collection
var $result : Text
Case of 
	: ($action="RunTests")
		UnitTest_RunTest("STR_HTML_Encode_LessThan")
		UnitTest_RunTest("STR_HTML_Encode_GreaterThan")
		UnitTest_RunTest("STR_HTML_Encode_DoubleQuote")
		UnitTest_RunTest("STR_HTML_Encode_SingleQuote")
		UnitTest_RunTest("STR_HTML_Encode_Mixed")
		UnitTest_RunTest("STR_HTML_Encode_PlainText")
		UnitTest_RunTest("STR_HTML_Encode_EmptyString")
		UnitTest_RunTest("STR_GetFlameGraphNameFromStack_EmptyStack")
		UnitTest_RunTest("STR_GetFlameGraphNameFromStack_SingleFrame")
		UnitTest_RunTest("STR_GetFlameGraphNameFromStack_MultipleFrames")
		
	: ($action="STR_HTML_Encode_LessThan")
		$result:=STR_HTML_Encode("<")
		UnitTest_Assert($result="&lt;"; "'<' should be encoded as '&lt;', got: "+$result)
		
	: ($action="STR_HTML_Encode_GreaterThan")
		$result:=STR_HTML_Encode(">")
		UnitTest_Assert($result="&gt;"; "'>' should be encoded as '&gt;', got: "+$result)
		
	: ($action="STR_HTML_Encode_DoubleQuote")
		$result:=STR_HTML_Encode("\"")
		UnitTest_Assert($result="&quot;"; "'\"' should be encoded as '&quot;', got: "+$result)
		
	: ($action="STR_HTML_Encode_SingleQuote")
		$result:=STR_HTML_Encode("'")
		UnitTest_Assert($result="&#39;"; "Single quote should be encoded as '&#39;', got: "+$result)
		
	: ($action="STR_HTML_Encode_Mixed")
		// <b>test</b> -> &lt;b&gt;test&lt;/b&gt;
		$result:=STR_HTML_Encode("<b>test</b>")
		UnitTest_Assert($result="&lt;b&gt;test&lt;/b&gt;"; "HTML tags should be fully encoded, got: "+$result)
		
	: ($action="STR_HTML_Encode_PlainText")
		// Plain text with no special characters should pass through unchanged
		$result:=STR_HTML_Encode("hello world 123")
		UnitTest_Assert($result="hello world 123"; "Plain text should be unchanged, got: "+$result)
		
	: ($action="STR_HTML_Encode_EmptyString")
		$result:=STR_HTML_Encode("")
		UnitTest_Assert($result=""; "Empty string should return empty string, got: "+$result)
		
	: ($action="STR_GetFlameGraphNameFromStack_EmptyStack")
		// Empty calling stack -> just the method name
		$stack:=New collection:C1472
		$result:=STR_GetFlameGraphNameFromStack("myMethod"; $stack)
		UnitTest_Assert($result="myMethod"; "Empty stack should return just the method name, got: "+$result)
		
	: ($action="STR_GetFlameGraphNameFromStack_SingleFrame")
		// One caller -> "caller;method"
		$stack:=New collection:C1472(New object:C1471("tag"; "callerMethod"))
		$result:=STR_GetFlameGraphNameFromStack("myMethod"; $stack)
		UnitTest_Assert($result="callerMethod;myMethod"; "Single-frame stack should produce 'caller;method', got: "+$result)
		
	: ($action="STR_GetFlameGraphNameFromStack_MultipleFrames")
		// callA -> callB -> myMethod = "callA;callB;myMethod"
		$stack:=New collection:C1472(\
			New object:C1471("tag"; "callA"); \
			New object:C1471("tag"; "callB"))
		$result:=STR_GetFlameGraphNameFromStack("myMethod"; $stack)
		UnitTest_Assert($result="callA;callB;myMethod"; "Multi-frame stack should produce full chain, got: "+$result)
		
End case 
