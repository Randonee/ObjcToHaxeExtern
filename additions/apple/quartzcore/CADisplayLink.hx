	static public inline var CADisplayLinkActionEvent:String = "CADisplayLinkActionEvent";
	
	static public function displayLinkWithHandler(handler:basis.object.IObject->String->Void):CADisplayLink
	{
		var objectID:String = cadisplaylink_displayLinkWithHandler();
		var object:IObject = BasisApplication.instance.objectManager.getObject(objectID);
		if(object != null)
		{
			var link:CADisplayLink = cast(object, CADisplayLink);
			link.addEventListener(CADisplayLinkActionEvent, handler);
			return cast(object, CADisplayLink);
		}

		return null;
	}
	private static var cadisplaylink_displayLinkWithHandler = Lib.load ("basis", "cadisplaylink_displayLinkWithHandler", 0);
	
	static public function getNSDefaultRunLoopMode():String{return cadisplaylink_getNSDefaultRunLoopMode();}
	private static var cadisplaylink_getNSDefaultRunLoopMode = Lib.load ("basis", "cadisplaylink_getNSDefaultRunLoopMode", 0);
	
	static public function getNSRunLoopCommonModes():String{return cadisplaylink_getNSRunLoopCommonModes();}
	private static var cadisplaylink_getNSRunLoopCommonModes = Lib.load ("basis", "cadisplaylink_getNSRunLoopCommonModes", 0);