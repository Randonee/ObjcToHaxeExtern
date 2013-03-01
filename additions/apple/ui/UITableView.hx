	static public function initWithFrameStyle(rect:Array<Float>, style:Int):UITableView
	{
		var objectID:String = uitableview_initWithFrameStyle(rect, style);
		var object:IObject = BasisApplication.instance.objectManager.getObject(objectID);
		if(object != null)
			return cast(object, UITableView);
			
		return null;
	}
	private static var uitableview_initWithFrameStyle = Lib.load ("basis", "uitableview_initWithFrameStyle", 2);

	public var dataSource(default, default):UITableViewDataSource;
	public var delegate(default, default):UITableViewDelegate;