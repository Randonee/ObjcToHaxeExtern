	static public function initWithContentsOfURLError(url:String):AVAudioPlayer
	{
		var objectID:String = avaudioplayer_initWithContentsOfURLError(url);
		var object:IObject = BasisApplication.instance.objectManager.getObject(objectID);
		if(object != null)
			return cast(object, AVAudioPlayer);

		return null;
	}
	private static var avaudioplayer_initWithContentsOfURLError = Lib.load ("basis", "avaudioplayer_initWithContentsOfURLError", 1);

	public var delegate(default, null):AVAudioPlayerDelegate;
	
	public function new(?type:Class<IObject>=null)
	{
		if(type == null)
			type = AVAudioPlayer;
		super(type);
		delegate = new AVAudioPlayerDelegate(this);
	}