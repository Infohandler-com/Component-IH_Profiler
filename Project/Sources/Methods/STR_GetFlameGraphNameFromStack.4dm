//%attributes = {"invisible":true,"preemptive":"capable"}
// STR_GetFlameGraphNameFromStack (methodName; callingStack) : flameGraphName
// STR_GetFlameGraphNameFromStack (text; pointer) text
// 
// DESCRIPTION
//   Returns the method name in a format that supports flamegraphs.
//
C_TEXT:C284($1; $methodName)
C_COLLECTION:C1488($2; $callingStack)
C_TEXT:C284($0; $flameGraphName)
// ----------------------------------------------------
// HISTORY
//   Created by: DB (05/22/2017)
//   Mod: DB (2020-02-07) - use collection
// ----------------------------------------------------

$flameGraphName:=""
If (Asserted:C1132(Count parameters:C259=2))
	ASSERT:C1129(Type:C295($2)=Is collection:K8:32)
	$methodName:=$1
	$callingStack:=$2
	
	C_OBJECT:C1216($event)
	For each ($event; $callingStack)
		$flameGraphName:=$flameGraphName+$event.tag+";"
	End for each 
	
	$flameGraphName:=$flameGraphName+$methodName
End if 
$0:=$flameGraphName