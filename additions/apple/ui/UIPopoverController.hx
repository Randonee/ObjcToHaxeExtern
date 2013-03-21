	static public function initWithContentViewController(controller:UIViewController):UIPopoverController
	{
		var objectID:String = uipopovercontroller_initWithContentViewController(controller.basisID);
		var object:IObject = BasisApplication.instance.objectManager.getObject(objectID);
		if(object != null)
			return cast(object, UIPopoverController);
		
		return null;
	}
	private static var uipopovercontroller_initWithContentViewController = Lib.load ("basis", "uipopovercontroller_initWithContentViewController", 1);
	
	public var delegate(default, null):UIPopoverControllerDelegate;
	
	public function new(?type:Class<IObject>=null)
	{
		if(type == null)
			type = UIPopoverController;
		super(type);
		delegate = new UIPopoverControllerDelegate(this);
	}