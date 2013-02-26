package org.objctohaxeextern;

import org.objctohaxeextern.Clazz;
import org.objctohaxeextern.Parser;

import sys.FileSystem;
import sys.io.File;
import sys.io.FileOutput;

class ExternExporter
{
	public var parser(default, null):Parser;
	private var _typesUsed:Map<String, Bool>;
	private var _typeObjToHaxe:Map<String, String>;
	
	private var _protocolMethods:Array<Method>;
	private var _protocolProperties:Array<Property>;
	private var _methodsWritten:Map<String, Bool>;
	
	public function new(parser:Parser):Void
	{
		this.parser = parser;
		createTypeConversionHash();
		_typesUsed = new Map<String, Bool>();
		_methodsWritten = new Map<String, Bool>();
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
				neko.Lib.println("Export " + clazz.name);
				if(content != "")
				{
					saveClass(savePath, content);
					content = "";
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
		_typesUsed = new Map<String, Bool>();
	
		packagePath = createClassPackage(clazz);
		contents += "package " + packagePath + ";\n\n";
		
		var subContents:String = createActuallClass(clazz);
		
		for(a in 0...clazz.classesInSameFile.length)
		{
			if(!(clazz.name != "NSObject" && clazz.classesInSameFile[a].name == "NSObject") )
				subContents += createActuallClass(clazz.classesInSameFile[a]);
		}
		
			
		//imports
		var imports:Map<String, Bool> = new Map<String, Bool>();
		for(type in _typesUsed.keys())
		{
			var importClass:Clazz = parser.classes.getHoldingClassForType(type);
			
			if(importClass != null)
			{
				if(!imports.exists(importClass.name))
				{
					imports.set(importClass.name, true);
					var importPackage:String = createClassPackage(importClass);
					if(importClass.name != clazz.name && importPackage != "")
						contents += "import " + importPackage + "." + importClass.name + ";\n" ;
				}
			}
		}
		
		contents += "\n" + subContents;
		return contents;
	}
	
	
	private function createActuallClass(clazz:Clazz):String
	{
		_protocolMethods = [];
		_protocolProperties = [];
		_methodsWritten = new Map<String, Bool>();
	
		if(clazz.name == "NSMutableArray")
		 return "";
	
		var subContents:String = "";
		
		if(clazz.hasDefinition)
		{
			subContents += createClassDefinition(clazz);
			subContents += "\n{\n";
			
			
			if(!clazz.isProtocol)
				subContents += "\n\t public function new();";
			
			subContents += "\n\t//Constants\n";
			for(a in 0...clazz.constants.length)
				subContents += "\t" + createConstant(clazz.constants[a]) + "\n";
			
				
			if(!clazz.isProtocol)
			{
				subContents += "\n\t//Static Methods\n";
				for(methods in clazz.staticMethods)
				{
					for(a in 0...methods.length)
					{
						if(!clazz.isMethodDefined(methods[a].name))
						{
							if(a > 0)
								subContents += "\t" + createOverrloadMeta(methods[a], clazz) + "\n"; 
						
							subContents += "\t" + createStaticMethod(methods[a], a, parser.classes.isStaticMothodDefinedInSuperClass(methods[a].name, clazz)) + "\n";
						}
					}
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
			
			if(_protocolMethods.length > 0 &&  !clazz.isProtocol)
			{
				subContents += "\n\n\t//Protocol Methods\n";
				for(a in 0..._protocolMethods.length)
				{
					if(!clazz.isMethodDefined(_protocolMethods[a].name) && !parser.classes.isMothodDefinedInSuperClass(_protocolMethods[a].name, clazz) && !_methodsWritten.exists(_protocolMethods[a].name))
					{
						subContents += "\t" + createMethod(_protocolMethods[a], 0, false) + "\n";
					}
				}
				
				
				subContents += "\n\n\t//Protocol Properties\n";
				for(a in 0..._protocolProperties.length)
				{
					subContents += "\t" + createProperty(_protocolProperties[a]) + "\n";
				}
			}
				
			subContents += "}\n\n";
		}
		
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
		var contents:String = "";
		
		if(clazz.isProtocol)
			contents += "extern interface " + clazz.name;
		else
			contents += "extern class " + clazz.name;
		
		if(clazz.parentClassName != "")
		{
			contents += " extends " + clazz.parentClassName;
			addTypeUsed(clazz.parentClassName);
		}
			
		var firstImpementAdded:Bool = true;
		for(a in 0...clazz.protocols.length)
		{
			if(clazz.protocols[a] != clazz.name && clazz.protocols[a] != "NSObject" && !parser.classes.doesSuperClassImplementProtocol(clazz.protocols[a], clazz))
			{
				if(!firstImpementAdded || clazz.parentClassName != "")
				{
					contents += ",";
					firstImpementAdded = false;	
				}
				contents += " implements " + clazz.protocols[a];
				addTypeUsed(clazz.protocols[a]);
				var protocolClass:Clazz = parser.classes.getClassForType(clazz.protocols[a]);
				
				if(protocolClass != null && protocolClass.isProtocol)
					addProtocolMethods(protocolClass);
			}
		}
		return contents;
	}
	
	private function addProtocolMethods(clazz:Clazz):Void
	{
		for(methods in clazz.methods)
		{
			for(a in 0...methods.length)
			{
				_protocolMethods.push(methods[a]);
			}
		}
		
		for(property in clazz.properties)
		{
			_protocolProperties.push(property);
		}
		
		for(a in 0...clazz.protocols.length)
		{
			var protocolClass:Clazz = parser.classes.getClassForType(clazz.protocols[a]);
			if(protocolClass != null && protocolClass.isProtocol)
				addProtocolMethods(protocolClass);
		}
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
	
	public function createStaticMethod(method:Method, ?overloadNum:Int = 0, ?overrides:Bool=false):String
	{
		var contents = "" ;
		if(method.sdk != "")
			contents += "@:require(" + method.sdk + ") " + contents;
	
		contents += "static " + createMethod(method, overloadNum, overrides, false);
		return contents;
	}
	
	public function createMethod(method:Method, ?overloadNum:Int = 0, ?overrides:Bool=false, ?addrequire:Bool=true):String
	{
		var contents = "" ;
		
		if(method.sdk != "" && addrequire)
			contents += "@:require(" + method.sdk + ") ";
		
		contents += "public ";
		
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
				
			addTypeUsed(argType);
			
			if(a > 0)
				contents += ", ";
			contents += " " + method.arguments[a].name + ":" + argType;
		}
		addTypeUsed(method.returnType);
		contents += "):" + getHaxeType(method.returnType) + ";";
		_methodsWritten.set(method.name, true);
		
		return contents;
	}
	
	public function createEnum(enumeration:Enumeration):String
	{
		if(enumeration.name == "{" || enumeration.name == "")
			return "";
	
		var contents = "extern enum " + enumeration.name + "\n";
		contents += "{";
		
		for(a in 0...enumeration.elements.length)
		{
			if( enumeration.elements[a].name.length <= 4)
				return "";
				
			contents += "\n\t" + enumeration.elements[a].name + ";";
		}
		
		contents += "\n}";
		
		return contents;
	}
	
	public function createStructure(structure:Structure):String
	{
		if(structure.name.charAt(0) == "_")
			return "";
	
		var contents = "extern class " + structure.name + "\n";
		contents += "{";
		
		contents += "\n\t public function new();";
		
		for(a in 0...structure.properties.length)
		{
			contents += "\n\t " + createProperty(structure.properties[a]);
		}
		
		contents += "\n}";
		
		return contents;
	}
	
	public function createConstant(constant:Constant):String
	{
		var contents = "//static public inline var " + constant.name + ":" + getHaxeType(constant.type) + ";";
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
		
		if(type.indexOf("const") >= 0)
			type = type.substring(0, type.indexOf("const")) + type.substr(type.indexOf("const") + 5);
		
		
		if(_typeObjToHaxe.exists(type))
			type = _typeObjToHaxe.get(type);
			
		if(type.indexOf("[") >= 0 && type.indexOf("]") >= 0)
			return "Array<Dynamic>";
			
		while( type.charAt(type.length-1) == "*")
			type = type.substring(0, type.length-1);
		
		
			
		//Not sure what to do with c Blocks. Making Dynamic for now
		if(type.indexOf("^") > -1)
			return "Dynamic";
			
		if(type.indexOf("<") >= 0 && type.indexOf(">") >= 0)
		{
			type = type.substring(type.indexOf("<") + 1, type.indexOf(">"));
		}
			
		return type;
	}
	
	private function addTypeUsed(type:String):Void
	{
	
		type = getHaxeType(type);
		if(type != "Void" && !_typesUsed.exists(type))
		{
			_typesUsed.set(type, true);
		}
	}
	
	private function createTypeConversionHash():Void
	{
		_typeObjToHaxe = new Map<String, String>();
		_typeObjToHaxe.set("int", "Int");
		_typeObjToHaxe.set("NSInteger", "Int");
		_typeObjToHaxe.set("NSInteger*", "Int");
		_typeObjToHaxe.set("NSUInteger*", "Int");
		_typeObjToHaxe.set("NSUInteger", "Int");
		_typeObjToHaxe.set("NSUInteger*", "Int");
		_typeObjToHaxe.set("unsignedint", "Int");
		_typeObjToHaxe.set("size_t", "Int");
		_typeObjToHaxe.set("int64_t", "Int");
		_typeObjToHaxe.set("int32_t", "Int");
		_typeObjToHaxe.set("uint32_t", "Int");
		_typeObjToHaxe.set("uint8_t", "Int");
		_typeObjToHaxe.set("uint8_t*", "Int");
		_typeObjToHaxe.set("NSStringEncoding", "Int");
		_typeObjToHaxe.set("NSStringEncoding*", "Int");
		_typeObjToHaxe.set("NSStringCompareOptions", "Int");
		_typeObjToHaxe.set("float", "Float");
		_typeObjToHaxe.set("NSTimeInterval", "Float");
		_typeObjToHaxe.set("UILayoutPriority", "Float");
		_typeObjToHaxe.set("CGFloat", "Float");
		_typeObjToHaxe.set("CGFloat*", "Float");
		_typeObjToHaxe.set("double", "Float");
		_typeObjToHaxe.set("CFTimeInterval", "Float");
		_typeObjToHaxe.set("CFTimeInterval*", "Float");
		_typeObjToHaxe.set("unsignedlong", "Float");
		_typeObjToHaxe.set("unsignedlong*", "Float");
		_typeObjToHaxe.set("bool", "Bool");
		_typeObjToHaxe.set("BOOL", "Bool");
		_typeObjToHaxe.set("NSString*", "String");
		_typeObjToHaxe.set("NSString", "String");
		_typeObjToHaxe.set("unichar", "String");
		_typeObjToHaxe.set("unichar*", "String");
		_typeObjToHaxe.set("__strongchar*", "String");
		_typeObjToHaxe.set("char", "String");
		_typeObjToHaxe.set("char*", "String");
		_typeObjToHaxe.set("UTF32Char", "String");
		_typeObjToHaxe.set("NSNumber*", "Float");
		_typeObjToHaxe.set("NSDate*", "Date");
		_typeObjToHaxe.set("void", "Void");
		_typeObjToHaxe.set("onewayvoid", "Void");
		_typeObjToHaxe.set("void*", "Void");
		_typeObjToHaxe.set("NSRangePointer", "NSRange");
		_typeObjToHaxe.set("id", "Dynamic");
		_typeObjToHaxe.set("id*", "Dynamic");
		_typeObjToHaxe.set("Class", "Class<Dynamic>");
		_typeObjToHaxe.set("void*", "Dynamic");
		_typeObjToHaxe.set("NSArray*", "Array<Dynamic>");
		_typeObjToHaxe.set("NSArray", "Array<Dynamic>");
		_typeObjToHaxe.set("IMP", "Dynamic");
		_typeObjToHaxe.set("Protocol*", "Dynamic");
		_typeObjToHaxe.set("unsigned", "Dynamic");
		_typeObjToHaxe.set("NSError**", "Dynamic");
		_typeObjToHaxe.set("NSComparisonResult", "Dynamic");
		_typeObjToHaxe.set("__unsafe_unretained*", "Dynamic");
		_typeObjToHaxe.set(",", "Dynamic");
		_typeObjToHaxe.set("CGContextRef", "Dynamic");
		_typeObjToHaxe.set("CGColorRef", "Dynamic");
		_typeObjToHaxe.set("CGPathRef", "Dynamic");
		_typeObjToHaxe.set("CGColorSpaceRef", "Dynamic");
		
		
		
		
		_typeObjToHaxe.set("NSZone", "Dynamic");
		_typeObjToHaxe.set("NSZone*", "Dynamic");
		
		
		
	}
}