	public function new(?type:Class<IObject>=null)
	{
		if(type == null)
			type = UIImagePickerController;
		super(type);
	}
	
	override private function createDelegate():Void
	{
		delegate = new UIImagePickerControllerDelegate(this);
	}
	
	public static function isSourceTypeAvailable(sourceType:Int):Bool
	{
		return uiimagepickercontroller_isSourceTypeAvailable(sourceType);
	}
	private static var uiimagepickercontroller_isSourceTypeAvailable = Lib.load ("basis", "uiimagepickercontroller_isSourceTypeAvailable", 1);