
	public function setCommands(commands:Array<String>):Void
	{
		nsspeechrecognizer_setCommands(basisID, commands);
	}
	private static var nsspeechrecognizer_setCommands = Lib.load ("basis", "nsspeechrecognizer_setCommands", 2);
	
	public var delegate(default, null):NSSpeechRecognizerDelegate;
	
	public function new(?type:Class<IObject>=null)
	{
		if(type == null)
			type = NSSpeechRecognizer;
		super(type);
		delegate = new NSSpeechRecognizerDelegate(this);
	}