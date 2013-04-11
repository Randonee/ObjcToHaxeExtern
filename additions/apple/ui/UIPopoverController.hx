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
	
	public var contentSizeForViewInPopover(get_contentSizeForViewInPopover, set_contentSizeForViewInPopover):Array<Float>;
	
	private function get_contentSizeForViewInPopover():Array<Float>
	{
		return BasisApplication.instance.objectManager.callInstanceMethod(this, "contentSizeForViewInPopover", [], [], TypeValues.CGSizeVal());
	}
	
	private function set_contentSizeForViewInPopover(value:Array<Float>):Array<Float>
	{
		BasisApplication.instance.objectManager.callInstanceMethod(this, "setContentSizeForViewInPopover:", [value], [TypeValues.CGSizeVal()], -1 );
		return contentSizeForViewInPopover;
	}
