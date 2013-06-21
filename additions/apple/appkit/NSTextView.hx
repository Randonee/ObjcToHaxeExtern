	public function insertNSAttributedString( text:NSAttributedString):Void
	{
		nstextview_insertNSAttributedString(basisID, text.basisID);
	}
	private static var nstextview_insertNSAttributedString = Lib.load ("basis", "nstextview_insertNSAttributedString", 2);
	
	public function insertString( text:String):Void
	{
		BasisApplication.instance.objectManager.callInstanceMethod(this, "insertString:", [text], [TypeValues.StringVal], -1);
	}