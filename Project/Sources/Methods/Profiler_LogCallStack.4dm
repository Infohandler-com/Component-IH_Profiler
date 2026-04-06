//%attributes = {"invisible":true,"shared":true,"preemptive":"capable"}
// Profiler_LogCallStack ({errorNo})
// 
// DESCRIPTION
//   Dumps the local process's call stack to the log.
//   Appends the errorNo if one is passed in.
//
#DECLARE($err : Integer)
Init_ThreadSafe

If (__STACK.length>0)
	C_TEXT:C284($vt_buffer)
	$vt_buffer:=String:C10(Current date:C33; 7)+" "+String:C10(Current time:C178; HH MM SS:K7:1)+" "  // Add the date & time
	$vt_buffer+="[p"+String:C10(Current process:C322; "000")
	
	// Output the user name if it is defined.
	C_TEXT:C284(WEB_t_userName)
	If (WEB_t_userName#"")
		$vt_buffer+=", "+WEB_t_userName
	End if 
	
	$vt_buffer+="]: ###### CALLING CHAIN DUMP"+Char:C90(Carriage return:K15:38)
	
	// Output the calling chain
	C_LONGINT:C283($i)
	For ($i; 0; __STACK.length-1)
		$vt_buffer+=" Lvl "+String:C10($i; "##00")+": "+("   "*($i))+__STACK[$i].tag
		If (__STACK[$i].extraText#"")
			$vt_buffer+=" -- "+__STACK[$i].extraText
		End if 
		$vt_buffer+=Char:C90(Carriage return:K15:38)
	End for 
	
	// Output our ERROR # 
	If ($err#0)
		$vt_buffer+=" Lvl "+String:C10(__STACK.length; "##00")+": "+("   "*(__STACK.length))+"above method triggered err #"+String:C10($err)+Char:C90(Carriage return:K15:38)
	End if 
	
	LogNamed_AppendToFile("Profiler Call Stack"; $vt_buffer)
End if 