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
		neko.Lib.println("-----  Parse startting -----");
		_pathBase = dirPath;
		readDirectory(dirPath);
		neko.Lib.println("-----  Parse Finished ------");
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
				neko.Lib.println("Parse: " + files[a]);
				var clazz:Clazz = parseClass(dirPath + "/" + files[a], StringTools.replace(dirPath, _pathBase, ""));
				classes.addClass(clazz);
			}
		}
	}
	
	private function parseClass(filePath:String, savePath):Clazz
	{
		var lexer:Lexer = new Lexer();
		var mainClazz:Clazz = new Clazz();
		var currentClazz:Clazz = mainClazz;
		
		mainClazz.savePath = savePath;
		
		var eReg:EReg = ~/([^\/]+)(?=\.\w+$)/;
		if(eReg.match(filePath))
			mainClazz.name = eReg.matched(1);
		
	    try
	    {
	    	var fin:FileInput = File.read(filePath, false);
	    	var tokens:Array<String> = [];
			while( true )
			{
				if(!lexer.instructionSpansToNextLine && tokens.length > 0)
				{	
					if(tokens.length > 0)
					{
						if(isClass(tokens) && tokens[2] == mainClazz.name)
						{
							currentClazz = mainClazz;
							currentClazz.hasDefinition = true;
							parseLine(tokens, currentClazz);
							currentClazz.isProtocol = (tokens[1] == "protocol");
						}
						else if(isClass(tokens))
						{
							currentClazz = mainClazz.getClassesInSameFile(tokens[2]);
							if(currentClazz == null)
							{
								currentClazz = new Clazz();
								currentClazz.hasDefinition = true;
								mainClazz.classesInSameFile.push(currentClazz);
							}
							parseLine(tokens, currentClazz);
							
						}
						else if(tokens[0] != "FOUNDATION_EXPORT")
						{
							parseLine(tokens, currentClazz);
						}
						
					}
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
		
		return mainClazz;
	}
	
	public function isClass(tokens:Array<String>):Bool
	{
		if(tokens[0] == "@" && (tokens[1] == "interface" || tokens[1] == "protocol"))
			return true;
			
		return false;
	}
	
	public function parseLine(tokens:Array<String>, clazz:Clazz):Void
	{
		if(tokens[tokens.length-1] == ";")
			tokens.pop();
		
		if(tokens[0] == "-" || tokens[0] == "+")
			parseMethod(tokens, clazz);
		else if(tokens[0] == "@" && tokens[1] == "property")
			parseProperty(tokens, clazz);
		else if(isClass(tokens))
			parseClassDefinition(tokens, clazz);
		else if( tokens[0] == "enum" )
			parseEnum(tokens, clazz);
		else if( tokens[0] == "const" || tokens[1] == "const" )
			parseConstant(tokens, clazz);
		else if( tokens[0] == "struct" || tokens[1] == "struct")
			parseStructure(tokens, clazz);
	}
	
	public function parseClassDefinition(tokens:Array<String>, clazz:Clazz):Void
	{
		if(clazz.name == "")
			clazz.name = tokens[2];
			
		if(tokens[1] == "protocol")
			clazz.isProtocol = true;
			
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
				{
					clazz.protocols.push(tokens[index + 1]);
				}
				++index;
			}
		}
	}
	
	public function isOnlyAvaialbleInSDK(str:String):Bool
	{
		if(str == "NS_AVAILABLE_IOS" || str == "bNS_DEPRECATED_IOS" || str == "bNS_AVAILABLE")
			return true;
			
		return false;
	}
	
	public function parseMethod(tokens:Array<String>, clazz:Clazz):Void
	{
		//token structure:[ "-", "(", "retyrnType", ")", "name", ":", "(", "arg1ype", ")", "name", ":", "(", "arg2type", ")"  ]
	
		var method:Method = {name:"", arguments:new Array<Argument>(), sdk:"", returnType:""};
		var isStatic:Bool = (tokens[0] == "+");
		
		method.returnType = getTokensBetweenParens(tokens, 1).join("");
		
		if(isOnlyAvaialbleInSDK(tokens[tokens.length - 4]))
		{
			method.sdk = "ios_" + tokens[tokens.length-2];
			tokens = tokens.slice(0, tokens.length - 4);
		}
		
		var index:Int=0;
		while(index < tokens.length && tokens[index] != ")")
			++index;
		
		++index;
		method.name = tokens[index];
		++index;
		while(index < tokens.length)
		{
			if(tokens[index] == "(")
			{
				var arg:Argument = {type:"", name:""};
				
				var argTokens:Array<String> = getTokensBetweenParens(tokens, index);
				arg.type = argTokens.join("");
				
				index += argTokens.length + 2;
				arg.name = tokens[index];
				
				if(arg.name == null || arg.type.indexOf(",") >= 0 )
				{
					neko.Lib.println("-- method skipped: " + method.name);
					return;
				}
				
				++index;
			
				method.arguments.push(arg);
			}
			
			++index;
		}
		
		if(method.name == "class")
			method.name = "clazz";
		else if(method.name == "new")
			method.name = "createNew";
		
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
		
		var property:Property = {name:"", readOnly:false, sdk:"", type:""};
		
		if(isOnlyAvaialbleInSDK(tokens[tokens.length - 4]))
		{
			property.sdk = "ios_" + tokens[tokens.length-2];
			tokens = tokens.slice(0, tokens.length - 4);
		}
		
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
	
	public function parseStructure(tokens:Array<String>, clazz:Clazz):Void
	{
		var name:String = "";
		
		var index:Int = 0;
		while(index < tokens.length && tokens[index] != "{")
			++index;
		
		if(tokens[0] == "typedef")
			name = tokens[tokens.length-1];
		else
			name = tokens[index-1];
		
		if(name == "struct")
			return;
	
		var structure:Structure = {name:name, properties:new Array<Property>()};
		
		
			
		++index;
		while(index < tokens.length && tokens[index] != "}")
		{
			var prop:Property = {name:"", readOnly:false, sdk:"", type:""};
			var more:Bool = true;
			
			while(more)
			{
				if(tokens[index] != "unsigned" )
					more = false;
				else
				{
					prop.type += tokens[index];
					++index;
				}
			}
			
			prop.type += tokens[index];
			++index;
			
			while(tokens[index] == "__unsafe_unretained")
				++index;
			
			while(tokens[index] == "*")
			{
				prop.type += tokens[index];
				++index;
			}
			
			prop.name = tokens[index];
			
			if(prop.name.indexOf("[") >= 0)
			{
				prop.name = prop.name.substring(0, prop.name.indexOf("["));
				prop.type = "NSArray";
			}
			
			structure.properties.push(prop);
			
			while(index < tokens.length && tokens[index] != ";")
			{
				if(tokens[index] == ",")
				{
					var prop2:Property = {name:tokens[index+1], readOnly:false, sdk:"", type:prop.type};
					structure.properties.push(prop2);
				}
				++index;
			}
				
			++index;
		}
		if(structure.properties.length > 0)
			clazz.structures.push(structure);
	}
	
	public function getTokensBetweenParens(tokens:Array<String>, pos:Int):Array<String>
	{
		var returnTokens:Array<String> = [];
		
		++pos;
		var more:Bool = true;
		var parenCount:Int = 1;
		while(more && pos < tokens.length)
		{
			if(tokens[pos] == "(")
				++parenCount;
			else if(tokens[pos] == ")")
				--parenCount;
			
			if(parenCount == 0)
				more = false;
			else
				returnTokens.push(tokens[pos]);
				
			++pos;
		}
		return returnTokens;
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