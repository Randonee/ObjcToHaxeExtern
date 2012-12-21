package org.objctohaxeextern;

import org.objctohaxeextern.Clazz;
import org.objctohaxeextern.Parser;

import sys.FileSystem;
import sys.io.File;
import sys.io.FileOutput;

class ExternExporter
{
	public var parser(default, null):Parser;
	private var _typesUsed:Hash<Bool>;
	private var _typeObjToHaxe:Hash<String>;
	
	public function new(parser:Parser):Void
	{
		this.parser = parser;
		createTypeConversionHash();
		_typesUsed = new Hash<Bool>();
	}
	
	public function export(destinationDirectory:String):Void
	{
		neko.Lib.println("-----  Export startting -----");
		Util.deleteDirectory(destinationDirectory);
		Util.createDirectory(destinationDirectory);
		
		var fout:FileOutput;
		var content:String = "";
		var savePath:String = "";
		for(clazz in parser.classes.items)
		{
			if(clazz.savePath != "")
			{
				if(content != "")
				{
					saveClass(savePath, content);
					content = "";
					
					neko.Lib.println("Export " + clazz.name);
				}
				
				savePath = destinationDirectory + "/" + clazz.savePath + "/" + clazz.name + ".hx";
				Util.createDirectory(destinationDirectory + "/" + clazz.savePath + "/");
				
				content += createClass(clazz);
			}
		}
		
		if(content != "")
			saveClass(savePath, content);
			
		neko.Lib.println("-----  Export Finished -----");
	}
	
	private function saveClass(path:String, content:String):Void
	{
		var fout:FileOutput = File.write(path , false);
		fout.writeString(content);
		fout.close();
	}
	
	
	public function createClass(clazz:Clazz):String
	{
		var contents:String = "";
		var packagePath:String = "";
	
		packagePath = createClassPackage(clazz);
		contents += "package " + packagePath + ";\n\n";
		
		var subContents:String = createActuallClass(clazz);
		
		for(a in 0...clazz.classesInSameFile.length)
			subContents += createActuallClass(clazz.classesInSameFile[a]);
		
			
		//imports
		for(type in _typesUsed.keys())
		{
			if(parser.classes.items.exists(type) )
			{
				var importClass:Clazz = parser.classes.items.get(type);
				var importPackage:String = createClassPackage(importClass);
				if(packagePath != importPackage)
					contents += "import " + importPackage + "." + importClass.name + ";\n" ;
			}
		}
		
		contents += "\n" + subContents;
		return contents;
	}
	
	
	private function createActuallClass(clazz:Clazz):String
	{
		if(clazz.name == "NSMutableArray")
		 return "";
	
		var subContents:String = createClassDefinition(clazz);
		subContents += "\n{\n";
		
		
		subContents += "\n\t//Constants\n";
		for(a in 0...clazz.constants.length)
			subContents += "\t" + createConstant(clazz.constants[a]) + "\n";
		
		subContents += "\n\t//Static Methods\n";
			
		for(methods in clazz.staticMethods)
		{
			for(a in 0...methods.length)
			{
				if(a > 0)
					subContents += "\t" + createOverrloadMeta(methods[a], clazz) + "\n"; 
				subContents += "\t" + createMethod(methods[a], a, parser.classes.isStaticMothodDefinedInSuperClass(methods[a].name, clazz)) + "\n";
			}
		}
		
		subContents += "\n\t//Properties\n";
		for(a in 0...clazz.properties.length)
			subContents += "\t" + createProperty(clazz.properties[a]) + "\n";
			
		subContents += "\n\t//Methods\n";
		for(methods in clazz.methods)
		{
			for(a in 0...methods.length)
			{
				if(a > 0)
					subContents += "\t" + createOverrloadMeta(methods[a], clazz) + "\n"; 
				subContents += "\t" + createMethod(methods[a], a, parser.classes.isMothodDefinedInSuperClass(methods[a].name, clazz)) + "\n";
			}
		}
			
		subContents += "}\n\n";
		
		for(a in 0...clazz.enumerations.length)
			subContents += createEnum(clazz.enumerations[a]) + "\n\n";
			
		for(a in 0...clazz.structures.length)
			subContents += createStructure(clazz.structures[a]) + "\n\n";
			
			
		return subContents;
	}
	
	public function createOverrloadMeta(method:Method, clazz:Clazz):String
	{
		var contents:String = "//@:overload !!NEED CUSTOM META DATA !!";
		return contents;
	}
	
	public function createClassDefinition(clazz:Clazz):String
	{
		var contents:String = "extern class " + clazz.name;
		
		if(clazz.parentClassName != "")
			contents += " extends " + clazz.parentClassName;
			
		for(a in 0...clazz.protocols.length)
		{
			if(a > 0 || clazz.parentClassName != "")
				contents += ",";
			
			contents += " implements " + clazz.protocols[a];
		}
		
		return contents;
	}
	
	public function createProperty(property:Property):String
	{
		var contents = "public var " + property.name + "(default, ";
		if(property.readOnly)
			contents += "null)";
		else
			contents += "default)";
			
		contents += ":" + getHaxeType(property.type) + ";";
		
		if(property.sdk != "")
			contents = "@:require(" + property.sdk + ") " + contents;
		
		addTypeUsed(property.type);
		return contents;
	}
	
	public function createStaticMethod(method:Method):String
	{
		return "static " + createMethod(method);
	}
	
	public function createMethod(method:Method, ?overloadNum:Int = 0, ?overrides:Bool=false):String
	{
		var contents = "public " ;
		
		
		if(method.sdk != "")
			contents = "@:require(" + method.sdk + ") " + contents;
		
		if(overrides)
			contents += "override";
		
		contents += " function " + method.name;
		
		if(overloadNum > 0)
			contents += Std.string(overloadNum);
			
		contents += "(";
		
		for(a in 0...method.arguments.length)
		{
			addTypeUsed(method.arguments[a].type);
			
			var argType:String = getHaxeType(method.arguments[a].type);
			if(argType == "Void")
				argType = "Dynamic";
			
			if(a > 0)
				contents += ", ";
			contents += " " + method.arguments[a].name + ":" + argType;
		}
		
		addTypeUsed(method.returnType);
		contents += "):" + getHaxeType(method.returnType) + ";";
		
		return contents;
	}
	
	public function createEnum(enumeration:Enumeration):String
	{
		var contents = "extern enum " + enumeration.name + "\n";
		contents += "{";
		
		for(a in 0...enumeration.elements.length)
		{
			contents += "\n\t" + enumeration.elements[a] + ";";
		}
		
		contents += "\n}";
		
		return contents;
	}
	
	public function createStructure(structure:Structure):String
	{
		var contents = "typedef " + structure.name + "\n";
		contents += "{";
		
		for(a in 0...structure.properties.length)
		{
			contents += "\n\t var " + structure.properties[a].name + ":" + structure.properties[a].type + ";";
		}
		
		contents += "\n}";
		
		return contents;
	}
	
	public function createConstant(constant:Constant):String
	{
		var contents = "//static public inline var " + constant.name + ":" + constant.type + ";";
		addTypeUsed(constant.type);
		return contents;
	}
	
	
	public function createClassPackage(clazz:Clazz):String
	{
		var packagePath:String = StringTools.replace(clazz.savePath, "/", ".");

		if(packagePath.charAt(0) == ".")
			packagePath = packagePath.substr(1);
			
		return packagePath;
	}
	
	public function getHaxeType(objcType:String):String
	{
		var type:String = objcType;
		if(_typeObjToHaxe.exists(objcType))
			type = _typeObjToHaxe.get(objcType);
			
		if(objcType.indexOf("[]") >= 0)
			return "Array<Dynamic>";
			
		if(type.charAt(type.length-1) == "*")
			type = type.substring(0, type.length-1);
			
		//Not sure what to do with c Blocks. Making Dynamic for now
		if(type.indexOf("^") > -1)
			type = "Dynamic";
			
		return type;
	}
	
	private function addTypeUsed(type:String):Void
	{
		if(type != "void" && getHaxeType(type) == type)
			_typesUsed.set(type, true);
	}
	
	private function createTypeConversionHash():Void
	{
		_typeObjToHaxe = new Hash<String>();
		_typeObjToHaxe.set("int", "Int");
		_typeObjToHaxe.set("NSInteger", "Int");
		_typeObjToHaxe.set("unsignedint", "Int");
		_typeObjToHaxe.set("float", "Float");
		_typeObjToHaxe.set("NSTimeInterval", "Float");
		_typeObjToHaxe.set("UILayoutPriority", "Float");
		_typeObjToHaxe.set("CGFloat", "Float");
		_typeObjToHaxe.set("bool", "Bool");
		_typeObjToHaxe.set("BOOL", "Bool");
		_typeObjToHaxe.set("double", "Float");
		_typeObjToHaxe.set("NSString*", "String");
		_typeObjToHaxe.set("NSNumber*", "Float");
		_typeObjToHaxe.set("NSDate*", "Date");
		_typeObjToHaxe.set("NSString*", "String");
		_typeObjToHaxe.set("NSString", "String");
		_typeObjToHaxe.set("void", "Void");
		_typeObjToHaxe.set("id", "Dynamic");
		_typeObjToHaxe.set("Class", "Class<Dynamic>");
		_typeObjToHaxe.set("void*", "Dynamic");
		_typeObjToHaxe.set("NSArray*", "Array<Dynamic>");
		_typeObjToHaxe.set("NSArray", "Array<Dynamic>");
	}
}