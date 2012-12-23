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
	public var properties(default, default):Array<Property>;
	public var methods(default, default):Hash<Array<Method>>;
	public var staticMethods(default, default):Hash<Array<Method>>;
	public var constants(default, null):Array<Constant>;
	public var enumerations(default, null):Array<Enumeration>;
	public var structures(default, null):Array<Structure>;
	public var savePath(default, default):String;
	public var classesInSameFile(default, default):Array<Clazz>;
	public var isProtocol(default, default):Bool;
	public var hasDefinition(default, default):Bool;
	
	public function new(?name:String = ""):Void
	{
		hasDefinition = false;
		this.name = name;
		parentClassName = "";
		savePath = "";
		isProtocol = false;
		protocols = [];
		properties = new Array<Property>();
		methods = new Hash<Array<Method>>();
		staticMethods = new Hash<Array<Method>>();
		enumerations = new Array<Enumeration>();
		structures = new Array<Structure>();
		constants = [];
		classesInSameFile = [];
	}
	
	public function getClassesInSameFile(name:String):Clazz
	{
		for(a in 0...classesInSameFile.length)
		{
			if(classesInSameFile[a].name == name)
				return classesInSameFile[a];
		}
		
		return null;
	}
	
	
	public function isStaticMethodDefined(name:String):Bool
	{
		return staticMethods.exists(name);
	}
	
	
	public function isMethodDefined(name:String):Bool
	{
		return methods.exists(name);
	}
	
	public function doesImplementProtocol(name:String):Bool
	{
		for(a in 0...protocols.length)
		{
			if(protocols[a] == name)
				return true;
		}
		return false;
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