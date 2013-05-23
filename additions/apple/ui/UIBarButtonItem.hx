	static public inline var UIBarButtonItemActionEvent:String = "UIBarButtonItemActionEvent";
	
	static public function initWithBarButtonSystemItem(systemItem:Int):UIBarButtonItem
	{
		var objectID:String = uibarbuttonitem_initWithBarButtonSystemItem(systemItem);
		var object:IObject = BasisApplication.instance.objectManager.getObject(objectID);
		if(object != null)
			return cast(object, UIBarButtonItem);

		return null;
	}
	private static var uibarbuttonitem_initWithBarButtonSystemItem = Lib.load ("basis", "uibarbuttonitem_initWithBarButtonSystemItem", 1);