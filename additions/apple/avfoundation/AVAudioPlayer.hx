	public var delegate(default, null):AVAudioPlayerDelegate;
	
	public function new(?type:Class<IObject>=null)
	{
		if(type == null)
			type = AVAudioPlayer;
		super(type);
		delegate = new AVAudioPlayerDelegate(this);
	}