	//Events
	public static inline function UITextFieldTextDidBeginEditing():String{ return "UITextFieldTextDidBeginEditing";}
	public static inline function UITextFieldTextDidChange():String{ return "UITextFieldTextDidChange";}
	public static inline function UITextFieldTextDidEndEditing():String{ return "UITextFieldTextDidEndEditing";}
	
	public var secureTextEntry(get_secureTextEntry, set_secureTextEntry) : Bool;
	private function set_secureTextEntry(value:Bool):Bool
	{
		cpp_uitextfield_set_secureTextEntry(basisID, value);
		return cpp_uitextfield_get_secureTextEntry(basisID);
	}
	private static var cpp_uitextfield_set_secureTextEntry = Lib.load("basis", "uitextfield_setSecureTextEntry", 2);
	private function get_secureTextEntry():Bool
	{
		return cpp_uitextfield_get_secureTextEntry(basisID);
	}
	private static var cpp_uitextfield_get_secureTextEntry = Lib.load("basis", "uitextfield_getSecureTextEntry", 1);

	public var fontSize(get_fontSize, set_fontSize) : Float;
	private function set_fontSize(value:Float):Float
	{
		cpp_uitextfield_set_fontSize(basisID, value);
		return cpp_uitextfield_get_fontSize(basisID);
	}
	private static var cpp_uitextfield_set_fontSize = Lib.load("basis", "uitextfield_setFontSize", 2);
	private function get_fontSize():Float
	{
		return cpp_uitextfield_get_fontSize(basisID);
	}
	private static var cpp_uitextfield_get_fontSize = Lib.load("basis", "uitextfield_getFontSize", 1);
