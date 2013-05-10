	public var delegate(default, null):UIApplicationDelegate;
	
	public function new(?type:Class<IObject>=null)
	{
		if(type == null)
			type = UIApplication;
		super(type);
		delegate = new UIApplicationDelegate();
	}