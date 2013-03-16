	public static inline function UIViewDidMoveToSuperview():String{ return "UIViewDidMoveToSuperview";}
	
	static public function animateWithDurationDelayOptionsAnimationsCompletion(duration:Float, delay:Float, options:Int, animationsHandler:Void->Void, compleationHander:Bool->Void)
	{
		uiview_animateWithDurationDelayOptionsAnimationsCompletion(duration, delay, options, animationsHandler, compleationHander);
	}
	private static var uiview_animateWithDurationDelayOptionsAnimationsCompletion = Lib.load ("basis", "uiview_animateWithDurationDelayOptionsAnimationsCompletion", 5);
	
	
	static public function animateWithDurationAnimationsCompletion(duration:Float, animationsHandler:Void->Void, compleationHander:Bool->Void)
	{
		uiview_animateWithDurationAnimationsCompletion(duration, animationsHandler, compleationHander);
	}
	private static var uiview_animateWithDurationAnimationsCompletion = Lib.load ("basis", "uiview_animateWithDurationAnimationsCompletion", 3);
	
	static public function animateWithDurationAnimations(duration:Float, animationsHandler:Void->Void)
	{
		uiview_animateWithDurationAnimations(duration, animationsHandler);
	}
	private static var uiview_animateWithDurationAnimations = Lib.load ("basis", "uiview_animateWithDurationAnimations", 2);
	
	
	static public function transitionWithViewDurationOptionsAnimationsCompletion(view:UIView, duration:Float, options:Int, animationsHandler:Void->Void, compleationHander:Bool->Void)
	{
		uiview_transitionWithViewDurationOptionsAnimationsCompletion(view.basisID, duration, options, animationsHandler, compleationHander);
	}
	private static var uiview_transitionWithViewDurationOptionsAnimationsCompletion = Lib.load ("basis", "uiview_transitionWithViewDurationOptionsAnimationsCompletion", 5);
	
	static public function transitionFromViewToViewDurationOptionsCompletion(toView:UIView, fromView:UIView, duration:Float, options:Int, compleationHander:Bool->Void)
	{
		uiview_transitionFromViewToViewDurationOptionsCompletion(fromView.basisID, toView.basisID, duration, options, compleationHander);
	}
	private static var uiview_transitionFromViewToViewDurationOptionsCompletion = Lib.load ("basis", "uiview_transitionFromViewToViewDurationOptionsCompletion", 5);