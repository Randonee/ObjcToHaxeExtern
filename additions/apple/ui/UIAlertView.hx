	public var delegate(default, null):UIAlertViewDelegate;
	
	public function new(?type:Class<IObject>=null)
	{
		if(type == null)
			type = UIAlertView;
		super(type);
		delegate = new UIAlertViewDelegate(this);
	}