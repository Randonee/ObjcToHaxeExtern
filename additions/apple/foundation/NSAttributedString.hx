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

#if osx
	static public function getNSFontAttributeName():String{return nsattributedstring_getNSFontAttributeName();}
	private static var nsattributedstring_getNSFontAttributeName = Lib.load ("basis", "nsattributedstring_getNSFontAttributeName", 0);
	
	static public function getNSParagraphStyleAttributeName():String{return nsattributedstring_getNSParagraphStyleAttributeName();}
	private static var nsattributedstring_getNSParagraphStyleAttributeName = Lib.load ("basis", "nsattributedstring_getNSParagraphStyleAttributeName", 0);
	
	static public function getNSForegroundColorAttributeName():String{return nsattributedstring_getNSForegroundColorAttributeName();}
	private static var nsattributedstring_getNSForegroundColorAttributeName = Lib.load ("basis", "nsattributedstring_getNSForegroundColorAttributeName", 0);
	
	static public function getNSUnderlineStyleAttributeName():String{return nsattributedstring_getNSUnderlineStyleAttributeName();}
	private static var nsattributedstring_getNSUnderlineStyleAttributeName = Lib.load ("basis", "nsattributedstring_getNSUnderlineStyleAttributeName", 0);
	
	static public function getNSSuperscriptAttributeName():String{return nsattributedstring_getNSSuperscriptAttributeName();}
	private static var nsattributedstring_getNSSuperscriptAttributeName = Lib.load ("basis", "nsattributedstring_getNSSuperscriptAttributeName", 0);
	
	static public function getNSBackgroundColorAttributeName():String{return nsattributedstring_getNSBackgroundColorAttributeName();}
	private static var nsattributedstring_getNSBackgroundColorAttributeName = Lib.load ("basis", "nsattributedstring_getNSBackgroundColorAttributeName", 0);
	
	static public function getNSAttachmentAttributeName():String{return nsattributedstring_getNSAttachmentAttributeName();}
	private static var nsattributedstring_getNSAttachmentAttributeName = Lib.load ("basis", "nsattributedstring_getNSAttachmentAttributeName", 0);
	
	static public function getNSLigatureAttributeName():String{return nsattributedstring_getNSLigatureAttributeName();}
	private static var nsattributedstring_getNSLigatureAttributeName = Lib.load ("basis", "nsattributedstring_getNSLigatureAttributeName", 0);
	
	static public function getNSBaselineOffsetAttributeName():String{return nsattributedstring_getNSBaselineOffsetAttributeName();}
	private static var nsattributedstring_getNSBaselineOffsetAttributeName = Lib.load ("basis", "nsattributedstring_getNSBaselineOffsetAttributeName", 0);
	
	static public function getNSKernAttributeName():String{return nsattributedstring_getNSKernAttributeName();}
	private static var nsattributedstring_getNSKernAttributeName = Lib.load ("basis", "nsattributedstring_getNSKernAttributeName", 0);
	
	static public function getNSLinkAttributeName():String{return nsattributedstring_getNSLinkAttributeName();}
	private static var nsattributedstring_getNSLinkAttributeName = Lib.load ("basis", "nsattributedstring_getNSLinkAttributeName", 0);
	
	static public function getNSStrokeWidthAttributeName():String{return nsattributedstring_getNSStrokeWidthAttributeName();}
	private static var nsattributedstring_getNSStrokeWidthAttributeName = Lib.load ("basis", "nsattributedstring_getNSStrokeWidthAttributeName", 0);
	
	static public function geNSStrokeColorAttributeNamet():String{return nsattributedstring_getNSStrokeColorAttributeName();}
	private static var nsattributedstring_getNSStrokeColorAttributeName = Lib.load ("basis", "nsattributedstring_getNSStrokeColorAttributeName", 0);
	
	static public function getNSUnderlineColorAttributeName():String{return nsattributedstring_getNSUnderlineColorAttributeName();}
	private static var nsattributedstring_getNSUnderlineColorAttributeName = Lib.load ("basis", "nsattributedstring_getNSUnderlineColorAttributeName", 0);
	
	static public function getNSStrikethroughStyleAttributeName():String{return nsattributedstring_getNSStrikethroughStyleAttributeName();}
	private static var nsattributedstring_getNSStrikethroughStyleAttributeName = Lib.load ("basis", "nsattributedstring_getNSStrikethroughStyleAttributeName", 0);
	
	static public function getNSStrikethroughColorAttributeName():String{return nsattributedstring_getNSStrikethroughColorAttributeName();}
	private static var nsattributedstring_getNSStrikethroughColorAttributeName = Lib.load ("basis", "nsattributedstring_getNSStrikethroughColorAttributeName", 0);
	
	static public function getNSShadowAttributeName():String{return nsattributedstring_getNSShadowAttributeName();}
	private static var nsattributedstring_getNSShadowAttributeName = Lib.load ("basis", "nsattributedstring_getNSShadowAttributeName", 0);
	
	static public function getNSObliquenessAttributeName():String{return nsattributedstring_getNSObliquenessAttributeName();}
	private static var nsattributedstring_getNSObliquenessAttributeName = Lib.load ("basis", "nsattributedstring_getNSObliquenessAttributeName", 0);
	
	static public function getNSExpansionAttributeName():String{return nsattributedstring_getNSExpansionAttributeName();}
	private static var nsattributedstring_getNSExpansionAttributeName = Lib.load ("basis", "nsattributedstring_getNSExpansionAttributeName", 0);
	
	static public function getNSCursorAttributeName():String{return nsattributedstring_getNSCursorAttributeName();}
	private static var nsattributedstring_getNSCursorAttributeName = Lib.load ("basis", "nsattributedstring_getNSCursorAttributeName", 0);
	
	static public function getNSToolTipAttributeName():String{return nsattributedstring_getNSToolTipAttributeName();}
	private static var nsattributedstring_getNSToolTipAttributeName = Lib.load ("basis", "nsattributedstring_getNSToolTipAttributeName", 0);
	
	static public function getNSMarkedClauseSegmentAttributeName():String{return nsattributedstring_getNSMarkedClauseSegmentAttributeName();}
	private static var nsattributedstring_getNSMarkedClauseSegmentAttributeName = Lib.load ("basis", "nsattributedstring_getNSMarkedClauseSegmentAttributeName", 0);
	
	static public function getNSWritingDirectionAttributeName():String{return nsattributedstring_getNSWritingDirectionAttributeName();}
	private static var nsattributedstring_getNSWritingDirectionAttributeName = Lib.load ("basis", "nsattributedstring_getNSWritingDirectionAttributeName", 0);
	
	static public function getNSVerticalGlyphFormAttributeName():String{return nsattributedstring_getNSVerticalGlyphFormAttributeName();}
	private static var nsattributedstring_getNSVerticalGlyphFormAttributeName = Lib.load ("basis", "nsattributedstring_getNSVerticalGlyphFormAttributeName", 0);
	
	static public function getNSTextAlternativesAttributeName():String{return nsattributedstring_getNSTextAlternativesAttributeName();}
	private static var nsattributedstring_getNSTextAlternativesAttributeName = Lib.load ("basis", "nsattributedstring_getNSTextAlternativesAttributeName", 0);
#end