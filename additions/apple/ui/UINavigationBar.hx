	public var delegate(default, null):UINavigationBarDelegate;
	
	public function new(?type:Class<IObject>=null)
	{
		if(type == null)
			type = UINavigationBar;
		super(type);
		delegate = new UINavigationBarDelegate(this);
	}