	public var contentSizeForViewInPopover(get_contentSizeForViewInPopover, set_contentSizeForViewInPopover):Array<Float>;
	
	private function get_contentSizeForViewInPopover():Array<Float>
	{
		return BasisApplication.instance.objectManager.callInstanceMethod(this, "contentSizeForViewInPopover", [], [], TypeValues.CGSizeVal());
	}
	
	private function set_contentSizeForViewInPopover(value:Array<Float>):Array<Float>
	{
		BasisApplication.instance.objectManager.callInstanceMethod(this, "setContentSizeForViewInPopover:", [value], [TypeValues.CGSizeVal()], -1 );
		return contentSizeForViewInPopover;
	}
