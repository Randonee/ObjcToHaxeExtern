	public var delegate(default, null):Dynamic;
	
	public function setDelegate( delegate:Dynamic):Void
	{
		BasisApplication.instance.objectManager.callInstanceMethod(this, "setDelegate:", [delegate], [TypeValues.ObjectVal], -1);
	}