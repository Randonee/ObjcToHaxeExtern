	public var dataSource(default, null):UIPickerViewDataSource;
	public var delegate(default, null):UIPickerViewDelegate;
	
	public function new(?type:Class<IObject>=null)
	{
		if(type == null)
			type = UIPickerView;
		super(type);
		dataSource = new UIPickerViewDataSource(this); 
		delegate = new UIPickerViewDelegate(this);
	}