//%attributes = {"invisible":true,"preemptive":"capable"}
// STR_HTML_Encode (source) : html_safe_text
// STR_HTML_Encode (text) : text
// 
// DESCRIPTION
//   Converts the supplied text to be HTML "safe".
//
#DECLARE($source : Text)->$html_safe_text : Text

If (Asserted:C1132(Count parameters:C259=1))
	$html_safe_text:=Replace string:C233($source; "<"; "&lt;")
	$html_safe_text:=Replace string:C233($html_safe_text; ">"; "&gt;")
	$html_safe_text:=Replace string:C233($html_safe_text; "\""; "&quot;")
	$html_safe_text:=Replace string:C233($html_safe_text; "'"; "&#39;")  //   Mod: DB (04/19/2017) - Task 3827
End if   // ASSERT
