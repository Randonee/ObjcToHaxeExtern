	public var delegate(default, null):AVAudioRecorderDelegate;
	
	public function new(?type:Class<IObject>=null)
	{
		if(type == null)
			type = AVAudioRecorder;
		super(type);
		delegate = new AVAudioRecorderDelegate(this);
	}