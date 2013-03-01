	static public function initWithStyleReuseIdentifier( style:Int,  reuseIdentifier:String):Dynamic
	{
		var objectID:String = uitableviewcell_initWithStyleReuseIdentifier(style, reuseIdentifier);
		var object:IObject = BasisApplication.instance.objectManager.getObject(objectID);
		if(object != null)
			return cast(object, UITableViewCell);
		
		return null;
	}
	private static var uitableviewcell_initWithStyleReuseIdentifier = Lib.load ("basis", "uitableviewcell_initWithStyleReuseIdentifier", 2);