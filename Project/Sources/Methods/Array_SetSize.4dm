//%attributes = {"invisible":true,"preemptive":"capable"}
// (PM) Array_SetSize
// Changes the size of one or multiple arrays
// $1 = Size
// $2 etc. = Pointers to arrays
#DECLARE($size : Integer)
var ${2} : Pointer  // TODO: Convert to variadic declaration in 21 LTS
var $param; $currentSize : Integer
var $array : Pointer

OnErr_Install_Handler("OnErr_GENERIC_Profiler")

If ($size<0)
	$size:=0
End if 

For ($param; 2; Count parameters:C259)
	
	$array:=${$param}
	$currentSize:=Size of array:C274($array->)
	Case of 
		: ($currentSize<$size)
			INSERT IN ARRAY:C227($array->; $currentSize+1; $size-$currentSize)
			
		: ($currentSize>$size)
			DELETE FROM ARRAY:C228($array->; $size+1; $currentSize-$size)
	End case 
	
End for 

OnErr_Install_Handler("")