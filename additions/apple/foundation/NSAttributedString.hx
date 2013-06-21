	static public function initWithString( text:String):NSMutableAttributedString
	{
		var id:String = nsattributedstring_initWithString(text);
		return cast(BasisApplication.instance.objectManager.getObject(id), NSMutableAttributedString);
	}
	private static var nsattributedstring_initWithString = Lib.load ("basis", "nsattributedstring_initWithString", 1);
	
	static public function initWithAttributedString( text:NSAttributedString):NSMutableAttributedString
	{
		var id:String = nsattributedstring_initWithAttributedString(text.basisID);
		return cast(BasisApplication.instance.objectManager.getObject(id), NSMutableAttributedString);
	}
	private static var nsattributedstring_initWithAttributedString = Lib.load ("basis", "nsattributedstring_initWithAttributedString", 1);