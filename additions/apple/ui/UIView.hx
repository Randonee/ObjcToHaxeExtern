	public static inline function UIViewDidMoveToSuperview():String{ return "UIViewDidMoveToSuperview";}
	
	static public function animateWithDuration(duration:Float, delay:Float, options:Int, animationsHandler:Void->Void, compleationHander:Bool->Void)
	{
		uiview_animateWithDuration(duration, delay, options, animationsHandler, compleationHander);
	}
	private static var uiview_animateWithDuration = Lib.load ("basis", "uiview_animateWithDuration", 5);
	