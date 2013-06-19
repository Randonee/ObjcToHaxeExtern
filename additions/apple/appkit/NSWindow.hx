	static public function initWithContentRectStyleMaskBackingDefer(rect:Array<Float>, windowStyle:Int, bufferingType:Int, deferCreation:Bool)
	{
		var objectID:String = nswindow_initWithContentRectStyleMaskBackingDefer(rect, windowStyle, bufferingType, deferCreation);
		var object:IObject = BasisApplication.instance.objectManager.getObject(objectID);
		
		if(object != null)
			return cast(object, NSWindow);

		return null;
	}
	private static var nswindow_initWithContentRectStyleMaskBackingDefer = Lib.load ("basis", "nswindow_initWithContentRectStyleMaskBackingDefer", 4);

	public var delegate(default, null):Dynamic;