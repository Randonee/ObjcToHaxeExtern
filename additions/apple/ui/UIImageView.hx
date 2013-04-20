	public function setImageFromURL(url:String):Void
	{
		uiimageview_setImageFromURL(basisID, url);
	}
	private static var uiimageview_setImageFromURL = Lib.load ("basis", "uiimageview_setImageFromURL", 2);