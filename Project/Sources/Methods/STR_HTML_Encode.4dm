//%attributes = {"invisible":true,"preemptive":"capable"}
// STR_HTML_Encode (srcTxt) : html safe txxt
// STR_HTML_Encode (text) : text
// 
// DESCRIPTION
//   Converts the supplied text to be HTML "safe".
//
C_TEXT:C284($1)
C_TEXT:C284($0; $vt_htmlSafeText)
// ----------------------------------------------------
// HISTORY
//   Created by: DB (11/05/09)
//   Mod: DB (04/19/2017) - Task 3827
// ----------------------------------------------------

$vt_htmlSafeText:=""
If (Asserted:C1132(Count parameters:C259=1))
	$vt_htmlSafeText:=Replace string:C233($1; "<"; "&lt;")
	$vt_htmlSafeText:=Replace string:C233($vt_htmlSafeText; ">"; "&gt;")
	$vt_htmlSafeText:=Replace string:C233($vt_htmlSafeText; "\""; "&quot;")
	$vt_htmlSafeText:=Replace string:C233($vt_htmlSafeText; "'"; "&#39;")  //   Mod: DB (04/19/2017) - Task 3827
End if   // ASSERT
$0:=$vt_htmlSafeText