	public var delegate(default, null):UINavigationControllerDelegate;
	public function new(?type:Class<IObject>=null)
	{
		if(type == null)
			type = UINavigationController;
		super(type);
		createDelegate();
	}
	
	private function createDelegate():Void
	{
		delegate = new UINavigationControllerDelegate(this);
	}