	static public function initWithURLSettings(url:String, settings:AVAudioSettings):AVAudioRecorder
	{
		var settingsArr:Array<Dynamic> = settings.getSettingsArray();
		var settingsUsed:Array<Bool> = [];
		
		for(item in settingsArr)
			settingsUsed.push(item != null);

		var objectID:String = avaudiorecorder_initWithURLSettings(url, settingsArr, settingsUsed);
		var object:IObject = BasisApplication.instance.objectManager.getObject(objectID);
		if(object != null)
			return cast(object, AVAudioRecorder);

		return null;
	}
	private static var avaudiorecorder_initWithURLSettings = Lib.load ("basis", "avaudiorecorder_initWithURLSettings", 3);
	
	public var delegate(default, null):AVAudioRecorderDelegate;
	
	public function new(?type:Class<IObject>=null)
	{
		if(type == null)
			type = AVAudioRecorder;
		super(type);
		delegate = new AVAudioRecorderDelegate(this);
	}