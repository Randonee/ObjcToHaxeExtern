	public var delegate(default, null):UIWebViewDelegate;
	
	public function new(?type:Class<IObject>=null)
	{
		if(type == null)
			type = UIWebView;
		super(type);
		delegate = new UIWebViewDelegate(this);
	}