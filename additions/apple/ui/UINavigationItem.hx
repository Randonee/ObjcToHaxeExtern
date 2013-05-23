	public function setLeftBarButtonItemsAnimated(items:Array<UIBarButtonItem>, anmated:Bool):Void
	{
		var itemIDs:Array<String> = [];
		for(item in items)
			itemIDs.push(item.basisID);
	
		uinavigationitem_setLeftBarButtonItemsAnimated(basisID, itemIDs, anmated);
	}
	private static var uinavigationitem_setLeftBarButtonItemsAnimated = Lib.load ("basis", "uinavigationitem_setLeftBarButtonItemsAnimated", 3);
	
	public function setRightBarButtonItemsAnimated(items:Array<UIBarButtonItem>, anmated:Bool):Void
	{
		var itemIDs:Array<String> = [];
		for(item in items)
			itemIDs.push(item.basisID);
	
		uinavigationitem_setRightBarButtonItemsAnimated(basisID, itemIDs, anmated);
	}
	private static var uinavigationitem_setRightBarButtonItemsAnimated = Lib.load ("basis", "uinavigationitem_setRightBarButtonItemsAnimated", 3);