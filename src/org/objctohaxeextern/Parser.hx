package org.objctohaxeextern;


import sys.FileSystem;
import sys.io.File;
import sys.io.FileInput;

import org.objctohaxeextern.Clazz;

class Parser
{
	public var classes(default, null):ClassCollection;
	
	private var _pathBase:String;
	
	public function new()
	{
		classes = new ClassCollection();
	}
	
	public function parseDirectory(dirPath:String):Void
	{
		_pathBase = dirPath;
		readDirectory(dirPath);
	}
	
	private function readDirectory(dirPath:String):Void
	{
		if(!FileSystem.exists(dirPath))
			return;
			
		var files:Array<String> = FileSystem.readDirectory(dirPath);
		for(a in 0...files.length)
		{
			if(FileSystem.isDirectory(dirPath + "/"+ files[a]))
			{
				readDirectory(dirPath + "/"+ files[a]);
			}
			else if( files[a].indexOf(".h") > 0 )
			{
				var clazz:Clazz = parseClass(dirPath + "/" + files[a]);
				clazz.savePath = StringTools.replace(dirPath, _pathBase, "");
				classes.addClass(clazz);
			}
		}
	}
	
	private function parseClass(filePath:String):Clazz
	{
		var lexer:Lexer = new Lexer();
		var clazz:Clazz = new Clazz();
		
	    try
	    {
	    	var fin:FileInput = File.read(filePath, false);
	    	var tokens:Array<String> = [];
			while( true )
			{
			
				if(!lexer.instructionSpansToNextLine && tokens.length > 0)
				{	
					if(tokens.length > 0)
						parseLine(tokens, clazz);
					tokens = [];
				}
				else
				{
					tokens = tokens.concat( lexer.createTokens(fin.readLine()) );
				}
			}
			
			fin.close();
		}
		catch( ex:haxe.io.Eof ) 
		{}
		
		return clazz;
	}
	
	public function parseLine(tokens:Array<String>, clazz:Clazz):Void
	{
		if(tokens[tokens.length-1] == ";")
			tokens.pop();
		
		if(tokens[0] == "-" || tokens[0] == "+")
			parseMethod(tokens, clazz);
		else if(tokens[0] == "@" && tokens[1] == "property")
			parseProperty(tokens, clazz);
		else if(tokens[0] == "@" && tokens[1] == "interface" && clazz.name == "")	//This just uses the first @inerface in the file
			parseClassDefinition(tokens, clazz);
		else if( tokens[0] == "enum" )
			parseEnum(tokens, clazz);
		else if( tokens[0] == "const" || tokens[1] == "const" )
			parseConstant(tokens, clazz);
	}
	
	public function parseClassDefinition(tokens:Array<String>, clazz:Clazz):Void
	{
		clazz.name = tokens[2];
		
		var index:Int = 3;
		if(tokens[index] == ":")
		{
			++index;
			clazz.parentClassName = tokens[index];
			++index;
		}
		
		if(tokens[index] == "<")
		{
			while(index < tokens.length && tokens[index] != ">")
			{
				if(tokens[index] == "," || tokens[index] == "<")
					clazz.protocols.push(tokens[index + 1]);
				++index;
			}
		}
	}
	
	public function parseMethod(tokens:Array<String>, clazz:Clazz):Void
	{
		//token structure:[ "-", "(", "retyrnType", ")", "name", ":", "(", "arg1ype", ")", "name", ":", "(", "arg2type", ")"  ]
	
		var method:Method = {name:"", arguments:new Array<Argument>(), returnType:""};
		var isStatic:Bool = (tokens[0] == "+");
		
		method.returnType = tokens[2];
		
		var index:Int=0;
		while(index < tokens.length && tokens[index] != ")")
			++index;
		
		++index;
		method.name = tokens[index];
		++index;
		
		var arg:String = "";
		var lastArg:Argument = {type:"---", name:"---"};
		var argCount:Int = 1;
		while(index < tokens.length)
		{
			if(tokens[index] == "(")
			{
				var arg:Argument = {type:"", name:""};
				
				if(method.arguments.length > 0 && tokens[index-2] != lastArg.name)
				{
					arg.name = tokens[index-2];
				}
				else
					arg.name = "arg" + Std.string(argCount);
			
				arg.type = tokens[index+1];
				if(arg.type == "struct" || arg.type == "unsigned")
					arg.type = tokens[index+2];
				
				method.arguments.push(arg);
				
				lastArg = arg;
			
				++argCount;
			}
			
			++index;
		}
		
		if(isStatic)
			clazz.addStaticMethod(method);
		else
			clazz.addMethod(method);
	}
	
	public function parseProperty(tokens:Array<String>, clazz:Clazz):Void
	{
		//token structure:[ "@", "property", "(", "option", ")", "type", "name"]
		
		if(tokens[tokens.length - 1] == ";")
			tokens.pop();
		
		var property:Property = {name:"", readOnly:false, type:""};
		
		var a:Int = 0;
		while(a < tokens.length && !property.readOnly)
		{
			property.readOnly = (tokens[a] == "readonly");
			++a;
		}
		
		
		if(tokens[tokens.length-2] == "=")
		{
			property.name = tokens[tokens.length-3];
			if(tokens[tokens.length-4] == "*")
				property.type = tokens[tokens.length-5];
			else
				property.type = tokens[tokens.length-4];
		}
		else
		{
			property.name = tokens[tokens.length-1];
			if(tokens[tokens.length-2] == "*")
				property.type = tokens[tokens.length-3];
			else
				property.type = tokens[tokens.length-2];
		}
		
		clazz.properties.push(property);
	}
	
	public function parseEnum(tokens:Array<String>, clazz:Clazz):Void
	{
		var enumeration:Enumeration = {name:tokens[1], elements:new Array<String>()};
		
		var index:Int = 0;
		
		while(index < tokens.length && tokens[index] != "{")
			++index;
			
		++index;
		
		while(index < tokens.length && tokens[index] != "}")
		{
		
			if(enumeration.elements.length == 0)
				enumeration.elements.push(tokens[index]);
			else
			{
				while(index < tokens.length && tokens[index] != ",")
					++index;
					
				++index;
				
				if(index < tokens.length && tokens[index] != "}")
					enumeration.elements.push(tokens[index]);
			}
		
			++index;
		}
		
		clazz.enumerations.push(enumeration);
		
	}
	
	
	public function parseConstant(tokens:Array<String>, clazz:Clazz):Void
	{
		var constant:Constant = {name:"", type:""};
		
		if(tokens[0] != "enum")
			tokens.shift();
			
		constant.type = tokens[1];
		
		if(tokens[2] != "*")
			constant.name = tokens[2];
		else
			constant.name = tokens[3];
			
		clazz.constants.push(constant);
	}

}