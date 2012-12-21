package org.objctohaxeextern;

typedef Argument = 
{
	type:String,
	name:String
}

typedef Property = 
{
	name:String,
	readOnly:Bool,
	sdk:String,
	type:String
}

typedef Method = 
{
	name:String,
	arguments:Array<Argument>,
	sdk:String,
	returnType:String
}

typedef Enumeration = 
{
	name:String,
	elements:Array<String>
}

typedef Structure = 
{
	name:String,
	properties:Array<Property>
}

typedef StaticProperty = 
{
	name:String,
	type:String
}

typedef Constant = 
{
	name:String,
	type:String,
}


class Clazz
{
	public var name(default, default):String;
	public var parentClassName(default, default):String;
	public var protocols(default, null):Array<String>;
	public var properties(default, null):Array<Property>;
	public var methods(default, null):Hash<Array<Method>>;
	public var staticMethods(default, null):Hash<Array<Method>>;
	public var constants(default, null):Array<Constant>;
	public var enumerations(default, null):Array<Enumeration>;
	public var structures(default, null):Array<Structure>;
	public var savePath(default, default):String;
	public var classesInSameFile(default, default):Array<Clazz>;
	
	public function new(?name:String = ""):Void
	{
		this.name = name;
		parentClassName = "";
		savePath = "";
		protocols = [];
		properties = new Array<Property>();
		methods = new Hash<Array<Method>>();
		staticMethods = new Hash<Array<Method>>();
		enumerations = new Array<Enumeration>();
		structures = new Array<Structure>();
		constants = [];
		classesInSameFile = [];
	}
	
	
	public function addMethod(method:Method):Void
	{
		if(!methods.exists(method.name))
			methods.set(method.name, new Array<Method>());
			
		methods.get(method.name).push(method);
	}
	
	public function addStaticMethod(method:Method):Void
	{
		if(!staticMethods.exists(method.name))
			staticMethods.set(method.name, new Array<Method>());
			
		staticMethods.get(method.name).push(method);
	}

}