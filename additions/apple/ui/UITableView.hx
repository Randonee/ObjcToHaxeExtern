	static public function initWithFrameStyle(rect:Array<Float>, style:Int):UITableView
	{
		var objectID:String = uitableview_initWithFrameStyle(rect, style);
		var object:IObject = BasisApplication.instance.objectManager.getObject(objectID);
		if(object != null)
			return cast(object, UITableView);
			
		return null;
	}
	private static var uitableview_initWithFrameStyle = Lib.load ("basis", "uitableview_initWithFrameStyle", 2);

	public var dataSource(default, null):UITableViewDataSource;
	public var delegate(default, null):UITableViewDelegate;
	
	public function new(?type:Class<IObject>=null)
	{
		if(type == null)
			type = UITableView;
		super(type);
		dataSource = new UITableViewDataSource(this); 
		delegate = new UITableViewDelegate(this);
	}