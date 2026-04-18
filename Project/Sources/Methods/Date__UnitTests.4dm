//%attributes = {"invisible":true,"preemptive":"incapable"}
// Date__UnitTests ($action)
// Unit tests for Date2String

#DECLARE($action : Text)

var $result : Text
Case of 
	: ($action="RunTests")
		UnitTest_RunTest("Date2String_DefaultFormat")
		UnitTest_RunTest("Date2String_ISOFormat")
		UnitTest_RunTest("Date2String_NullDateReturnsEmpty")
		UnitTest_RunTest("Date2String_MonthName")
		UnitTest_RunTest("Date2String_MonthAbbrev")
		UnitTest_RunTest("Date2String_EUFormat")
		UnitTest_RunTest("Date2String_SingleDigitDay")
		UnitTest_RunTest("Date2String_TwoDigitYear")
		UnitTest_RunTest("Date2String_DecemberLastDay")
		
	: ($action="Date2String_DefaultFormat")
		// !2025-01-15! = January 15, 2025 -> "01/15/2025"
		$result:=Date2String(!2025-01-15!; "")
		UnitTest_Assert($result="01/15/2025"; "Default format for Jan 15, 2025 should be '01/15/2025', got: "+$result)
		
	: ($action="Date2String_ISOFormat")
		// !2025-01-15! with "yyyymmdd" -> "20250115"
		$result:=Date2String(!2025-01-15!; "yyyymmdd")
		UnitTest_Assert($result="20250115"; "ISO format for Jan 15, 2025 should be '20250115', got: "+$result)
		
	: ($action="Date2String_NullDateReturnsEmpty")
		// Null/zero date should return empty string
		$result:=Date2String(!00-00-00!; "")
		UnitTest_Assert($result=""; "Null date '!00-00-00!' should return empty string, got: "+$result)
		
	: ($action="Date2String_MonthName")
		// !2025-01-15! with "Month dd, yyyy" -> "January 15, 2025"
		$result:=Date2String(!2025-01-15!; "Month dd, yyyy")
		UnitTest_Assert($result="January 15, 2025"; "Month name format for Jan 15 should be 'January 15, 2025', got: "+$result)
		
	: ($action="Date2String_MonthAbbrev")
		// !2025-03-15! with "Mon-dd-yyyy" -> "Mar-15-2025"
		$result:=Date2String(!2025-03-15!; "Mon-dd-yyyy")
		UnitTest_Assert($result="Mar-15-2025"; "Month abbreviation for March 15 should be 'Mar-15-2025', got: "+$result)
		
	: ($action="Date2String_EUFormat")
		// !2025-01-05! with "dd/mm/yyyy" -> "05/01/2025"
		$result:=Date2String(!2025-01-05!; "dd/mm/yyyy")
		UnitTest_Assert($result="05/01/2025"; "EU format for Jan 5, 2025 should be '05/01/2025', got: "+$result)
		
	: ($action="Date2String_SingleDigitDay")
		// !2025-01-05! with "d1/mm/yyyy" -> "5/01/2025"
		$result:=Date2String(!2025-01-05!; "d1/mm/yyyy")
		UnitTest_Assert($result="5/01/2025"; "Single-digit day format for Jan 5 should be '5/01/2025', got: "+$result)
		
	: ($action="Date2String_TwoDigitYear")
		// !2025-12-31! with "yy-mm-dd" -> "25-12-31"
		$result:=Date2String(!2025-12-31!; "yy-mm-dd")
		UnitTest_Assert($result="25-12-31"; "Two-digit year format for Dec 31, 2025 should be '25-12-31', got: "+$result)
		
	: ($action="Date2String_DecemberLastDay")
		// !2025-12-31! with "mm/dd/yyyy" -> "12/31/2025"
		$result:=Date2String(!2025-12-31!; "mm/dd/yyyy")
		UnitTest_Assert($result="12/31/2025"; "Dec 31, 2025 with mm/dd/yyyy should be '12/31/2025', got: "+$result)
		
End case 
