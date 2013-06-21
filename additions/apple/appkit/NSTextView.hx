	public function insertNSAttributedString( text:apple.foundation.NSAttributedString):Void
	{
		nstextview_insertNSAttributedString(basisID, text.basisID);
	}
	private static var nstextview_insertNSAttributedString = Lib.load ("basis", "nstextview_insertNSAttributedString", 2);
	
	public function insertString( text:String):Void
	{
		BasisApplication.instance.objectManager.callInstanceMethod(this, "insertString:", [text], [TypeValues.StringVal], -1);
	}
	
	public var delegate(default, null):NSTextViewDelegate;
	
	public function new(?type:Class<IObject>=null)
	{
		if(type == null)
			type = NSTextView;
		super(type);
		delegate = new NSTextViewDelegate(this);
	}