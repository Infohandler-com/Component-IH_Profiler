//%attributes = {"invisible":true,"preemptive":"capable"}
// Performance_UpdateTrackingObj (trackingObject, trackingName, timeSpentInMethod) 
// Performance_UpdateTrackingObj (object, text, longint) 
//
// DESCRIPTION
//   Capture the current metrics into the performance tracking object.
//
#DECLARE($trackingObject : Object; $trackingName : Text; $timeSpentInMethod : Integer)

If (Asserted:C1132(Count parameters:C259=3))
	$trackingName:=Replace string:C233($trackingName; " "; "_")
	
	If ($trackingName="_numItems")  // work around a potential collision with our counter
		$trackingName+=" "
	End if 
	
	ASSERT:C1129($trackingObject#Null:C1517)
	
	C_OBJECT:C1216($perfObj)
	If ($trackingObject[$trackingName]=Null:C1517)
		$perfObj:=New object:C1471
		$perfObj.min:=$timeSpentInMethod  // starting values
		$perfObj.max:=$timeSpentInMethod  // starting values
		$perfObj.total:=$timeSpentInMethod
		$perfObj.callCount:=1
		$trackingObject[$trackingName]:=$perfObj
		
		$trackingObject._numItems+=1
		
	Else 
		$perfObj:=$trackingObject[$trackingName]
		
		If ($perfObj.min>$timeSpentInMethod)
			$perfObj.min:=$timeSpentInMethod
		End if 
		If ($perfObj.max<$timeSpentInMethod)
			$perfObj.max:=$timeSpentInMethod
		End if 
		
		$perfObj.total+=$timeSpentInMethod
		$perfObj.callCount+=1
	End if 
	
End if 