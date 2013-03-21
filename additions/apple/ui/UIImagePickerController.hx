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