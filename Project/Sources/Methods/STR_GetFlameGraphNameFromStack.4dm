//%attributes = {"invisible":true,"preemptive":"capable"}
// STR_GetFlameGraphNameFromStack (methodName; callingStack) : flameGraphName
// STR_GetFlameGraphNameFromStack (text; pointer) text
// 
// DESCRIPTION
//   Returns the method name in a format that supports flamegraphs.
//
#DECLARE($methodName : Text; $callingStack : Collection)->$flameGraphName : Text

If (Asserted:C1132(Count parameters:C259=2))
	ASSERT:C1129(Type:C295($callingStack)=Is collection:K8:32)
	
	var $event : Object
	For each ($event; $callingStack)
		$flameGraphName+=$event.tag+";"
	End for each 
	
	$flameGraphName+=$methodName
End if 
