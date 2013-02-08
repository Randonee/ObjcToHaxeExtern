package org.objctohaxeextern;

import org.objctohaxeextern.Clazz;
import org.objctohaxeextern.Parser;

import sys.FileSystem;
import sys.io.File;
import sys.io.FileOutput;

class BasisAppleExporter
{
	private static inline var TYPES_TO_IGNORE:Array<String> = ["CALayer", "NSCoder", "Void", "NSArray", "NSLayoutConstraint", "UIGestureRecognizer", "UIEvent", "UIImage", "NSAttributedString"];

	public var parser(default, null):Parser;
	private var _typesUsed:Hash<Bool>;
	private var _typeObjToHaxe:Hash<String>;
	
	private var _protocolMethods:Array<Method>;
	private var _protocolProperties:Array<Property>;
	private var _methodsWritten:Hash<Bool>;
	
	private var _currentCppClassContent:String;
	private var _currentHxClassContent:String;
	
	private var _enumNames:Array<String>;
	
	
	public function new(parser:Parser):Void
	{
		this.parser = parser;
		createTypeConversionHash();
		_enumNames = [];
	}
	
	public function export(destinationDirectory:String):Void
	{
		neko.Lib.println("-----  Export startting -----");
		Util.deleteDirectory(destinationDirectory);
		Util.createDirectory(destinationDirectory);
		
		
		for(clazz in parser.classes.items)
		{
			for(subclass in clazz.classesInSameFile)
				addEnumNames(subclass.enumerations);
		
			addEnumNames(clazz.enumerations);
		}
		
		_enumNames.push("NSLayoutAttribute");
		_enumNames.push("UILayoutPriority");
		
		
		var cppSavePath:String = "";
		var hxSavePath:String = "";
		for(clazz in parser.classes.items)
		{
			_currentCppClassContent = "";
			_currentHxClassContent = "";
			if(! clazz.isProtocol)
			{
				neko.Lib.println("Export " + clazz.name);
				
				cppSavePath = destinationDirectory + "/cpp/" + clazz.savePath + "/" + clazz.name + ".mm";
				hxSavePath = destinationDirectory + "/hx/" + clazz.savePath + "/" + clazz.name + ".hx";
				Util.createDirectory(destinationDirectory + "/cpp/" + clazz.savePath + "/");
				Util.createDirectory(destinationDirectory + "/hx/" + clazz.savePath + "/");
				
				createClass(clazz);
				
				if(hxSavePath != "" && clazz.savePath != "")
				{
					saveClass(cppSavePath, _currentCppClassContent);
					saveClass(hxSavePath, _currentHxClassContent);
					cppSavePath = "";
					hxSavePath = "";
				}
			}
		}
		
		neko.Lib.println("-----  Export Finished -----");
	}
	
	private function addEnumNames(enums:Array<Enumeration>):Void
	{
		for(enumeration in enums)
		{
			_enumNames.push(enumeration.name);
			for(element in enumeration.elements)
			{
				_enumNames.push(element.name);
			}
		}
	}
	
	private function saveClass(path:String, content:String):Void
	{
		var fout:FileOutput = File.write(path , false);
		fout.writeString(content);
		fout.close();
	}
	
	
	public function createClass(clazz:Clazz):Void
	{
		var packagePath:String = "";
		_typesUsed = new Hash<Bool>();
	
		packagePath = createClassPackage(clazz);
		
		_currentHxClassContent += "//This code was generated using ObjcToHaxeExtern\n";
		_currentHxClassContent += "//https://github.com/Randonee/ObjcToHaxeExtern\n\n";
		
		_currentHxClassContent += "package " + packagePath + ";\n\n";
		
		_currentHxClassContent += "import cpp.Lib;\n";
		_currentHxClassContent += "import ios.ViewManager;\n";
		_currentHxClassContent += "import ios.ViewBase;\n";
		_currentHxClassContent += "\n";
		
		//----- CPP
		_currentCppClassContent += "//This code was generated using ObjcToHaxeExtern\n";
		_currentCppClassContent += "//https://github.com/Randonee/ObjcToHaxeExtern\n\n";
		_currentCppClassContent += "namespace basis\n";
		_currentCppClassContent += "{\n";
		//----- 
		
		createActuallClass(clazz);
		
		//----- CPP
		_currentCppClassContent += "}";
		//----- 
	}
	
	private function createActuallClass(clazz:Clazz):Void
	{
		_protocolMethods = [];
		_protocolProperties = [];
		_methodsWritten = new Hash<Bool>();
	
		if(clazz.name == "NSMutableArray")
		 return;
	
		
		if(clazz.hasDefinition)
		{
			createClassDefinition(clazz);
			_currentHxClassContent += "\n{\n";
			
			_currentHxClassContent += "\n\t public function new(?type=\"" + clazz.name + "\")\n";
			_currentHxClassContent += "\t{\n";
			_currentHxClassContent += "\t\tsuper(type);\n";
			_currentHxClassContent += "\t}\n";
			
			_currentHxClassContent += "\n\t//Constants\n";
			for(a in 0...clazz.constants.length)
			{
				_currentHxClassContent += "\t";
				createConstant(clazz.constants[a]);
				_currentHxClassContent += "\n";
			}
			
			
			/*
			_currentHxClassContent += "\n\t//Static Methods\n";
			for(methods in clazz.staticMethods)
			{
				for(a in 0...methods.length)
				{
					if(!clazz.isMethodDefined(methods[a].name))
					{
						if(a > 0)
							_currentHxClassContent += "\t" + createOverrloadMeta(methods[a], clazz) + "\n"; 
					
						_currentHxClassContent += "\t" + createStaticMethod(methods[a], a, parser.classes.isStaticMothodDefinedInSuperClass(methods[a].name, clazz)) + "\n";
					}
				}
			}*/
			
			
			_currentHxClassContent += "\n\t//Properties\n";
			for(a in 0...clazz.properties.length)
			{
				createProperty(clazz.properties[a], clazz) + "\n";
			}
				
			_currentHxClassContent += "\n\t//Methods\n";
			for(methods in clazz.methods)
			{
				for(a in 0...methods.length)
				{
					createMethod(methods[a], clazz, a, parser.classes.isMothodDefinedInSuperClass(methods[a].name, clazz)) + "\n";
				}
			}
			
			if(_protocolMethods.length > 0 &&  !clazz.isProtocol)
			{
				_currentHxClassContent += "\n\n\t//Protocol Methods\n";
				for(a in 0..._protocolMethods.length)
				{
					if(!clazz.isMethodDefined(_protocolMethods[a].name) && !parser.classes.isMothodDefinedInSuperClass(_protocolMethods[a].name, clazz) && !_methodsWritten.exists(_protocolMethods[a].name))
					{
						createMethod(_protocolMethods[a], clazz, 0, false) + "\n";
					}
				}
				
				
				_currentHxClassContent += "\n\n\t//Protocol Properties\n";
				for(a in 0..._protocolProperties.length)
				{
					createProperty(_protocolProperties[a], clazz) + "\n";
				}
			}
				
			
		}
		
		_currentHxClassContent += "\n\n";
		
		for(a in 0...clazz.enumerations.length)
			createEnum(clazz.enumerations[a]);
			
		_currentHxClassContent += "\n\n";
		
		/*
		for(a in 0...clazz.structures.length)
		{
			createStructure(clazz.structures[a], clazz);
			_currentHxClassContent += "\n\n";
		}
		*/
		_currentHxClassContent += "}\n\n";
	}
	
	
	public function createClassDefinition(clazz:Clazz):Void
	{
		_currentHxClassContent += "class " + clazz.name;
		
		if(clazz.parentClassName != "")
		{
			_currentHxClassContent += " extends " + clazz.parentClassName;
			addTypeUsed(clazz.parentClassName);
		}
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
			var protocolClass:Clazz = parser.classes.getClassForType(clazz.protocols[a], false);
			if(protocolClass != null && protocolClass.isProtocol)
				addProtocolMethods(protocolClass);
		}
	}
	
	public function createProperty(property:Property, clazz:Clazz):Void
	{
		if(shouldIgnorType(property.type) || property.deprecated || property.name == "tag")
			return;
			
		var propNameUpper:String = property.name.charAt(0).toUpperCase() + property.name.substring(1);
		var cppGetName:String = clazz.name.toLowerCase() + "_get" + propNameUpper;
		var cppSetName:String = clazz.name.toLowerCase() + "_set" + propNameUpper;
		var argType:String = getHaxeType(property.type);
	
		_currentHxClassContent += "\tpublic var " + property.name + "(get" + propNameUpper + ", ";
		if(property.readOnly)
			_currentHxClassContent += "null)";
		else
			_currentHxClassContent += "set" + propNameUpper + ")";
			
		_currentHxClassContent += ":" + argType + ";\n";
		
		_currentHxClassContent += "\tprivate function get" + propNameUpper + "():" + argType + "\n";
		_currentHxClassContent += "\t{\n";
		if(isUIClass(parser.classes.getClassForType(argType, false)))
		{
			_currentHxClassContent += "\t\tvar viewTag:Int = "  + cppGetName + "(_tag);\n";
			_currentHxClassContent += "\t\treturn cast(ViewManager.getView(viewTag), " + argType +");\n";
		}
		else
		{	
			_currentHxClassContent += "\t\treturn " + cppGetName + "(_tag);\n";
		}
		_currentHxClassContent += "\t}\n";
		_currentHxClassContent += "\tprivate static var " + cppGetName + " = Lib.load(\"basis\", \"" + cppGetName + "\", 1);\n";
		
		if(!property.readOnly)
		{
			_currentHxClassContent += "\n";
			_currentHxClassContent += "\tprivate function set" + propNameUpper + "(value:" + argType + "):" + argType + "\n";
			_currentHxClassContent += "\t{\n";
			
			
			if(isUIClass(parser.classes.getClassForType(argType, false)))
			{
				_currentHxClassContent += "\t\t" + cppSetName + "(_tag, value.tag);\n";
				_currentHxClassContent += "\t\tvar viewTag:Int = " + cppGetName + "(_tag)\n";
				_currentHxClassContent += "\t\treturn cast(ViewManager.getView(viewTag), " + argType +");\n";
			}
			else
			{
				_currentHxClassContent += "\t\t" + cppSetName + "(_tag, value);\n";
				_currentHxClassContent += "\t\treturn " + cppGetName + "(_tag);\n";
			}
			
			
			_currentHxClassContent += "\t}\n";
			_currentHxClassContent += "\tprivate static var " + cppSetName + " = Lib.load(\"basis\", \"" + cppSetName + "\", 2);\n";
		}
		_currentHxClassContent += "\n";
		
		
		//---- CPP
		_currentCppClassContent += "\tvalue " + cppGetName + "(value tag)\n";
		_currentCppClassContent += "\t{\n";
		_currentCppClassContent += "\t\t" + clazz.name + " *view = (" + clazz.name + "*)[[BasisApplication getViewManager] getView:val_int(tag)];\n";
		if(isUIClass(parser.classes.getClassForType(argType, false)))
		{
			_currentCppClassContent += "\t\t" + property.type + " viewVar = (" + property.type + ")view." + property.name + ";\n";
			_currentCppClassContent += "\t\treturn alloc_int(viewVar.tag);\n";
		}
		else
		{
			_currentCppClassContent += "\t\t" + property.type + " returnVar = (" + property.type + ")view." + property.name + ";\n";
			_currentCppClassContent += "\t\treturn " + getCppToHaxe("returnVar", property.type) + ";\n";
		}
		
		_currentCppClassContent += "\t}\n";
		_currentCppClassContent += "\tDEFINE_PRIM (" + cppGetName  + ", 1);\n";
		
		if(!property.readOnly)
		{
			_currentCppClassContent += "\tvoid " + cppSetName + "(value tag, value arg1)\n";
			_currentCppClassContent += "\t{\n";
			_currentCppClassContent += "\t\t" + clazz.name + " *view = (" + clazz.name + "*)[[BasisApplication getViewManager] getView:val_int(tag)];\n";
			if(isUIClass(parser.classes.getClassForType(argType, false)))
			{
				_currentCppClassContent += "\t\t" + property.type + " viewVar = (" + property.type + ")[[BasisApplication getViewManager] getView:val_int(arg1)];\n";
				_currentCppClassContent += "\t\t" + "view." + property.name + " = viewVar;\n";
			}
			else
			{
				_currentCppClassContent += "\t\t" + "view." + property.name + " = " +  getHaxeToCpp("arg1", property.type) + ";\n";
			}
			_currentCppClassContent += "\t}\n";
			_currentCppClassContent += "\tDEFINE_PRIM (" + cppSetName  + ", 2);\n\n\n";
		}
		//-----
		
	}
	
	public function shouldIgnorType(type:String):Bool
	{
		type = StringTools.replace(type, "*", "");
		for(a in 0...TYPES_TO_IGNORE.length)
		{
			if(type == TYPES_TO_IGNORE[a])
				return true;
		}
		
		return false;
	}
	
	public function getHaxeToCpp(name:String, type:String):String
	{
		type = StringTools.replace(type, "*", "");
		var content:String = "";
	
		switch(type)
		{
			case "CGRect":
				return "arrayToCGRect(" + name + ")";
			
			case "CGPoint":
				return "arrayToCGPoint(" + name + ")";
			
			case "CGSize":
				return "arrayToCGSize(" + name + ")";
			
			case "CGAffineTransform":
				return "arrayToCGAffineTransform(" + name + ")";
			
			case "UIColor":
				return "[UIColor colorWithCGColor:arrayToCGColor(" + name + ")]";
			case "int":
				return "val_int(" + name + ")";
				
			case "NSInteger":
				return "val_int(" + name + ")";
				
			case "float":
				return "val_float(" + name + ")";
				
			case "CGFloat":
				return "val_float(" + name + ")";
			
			case "BOOL":
				return "val_bool(" + name + ")";
				
			case "NSString":
				return "[NSString stringWithCString:val_string(" + name + ")encoding:NSUTF8StringEncoding]";
				
			case "UIEdgeInsets":
				return "arrayToUIEdgeInsets(" + name + ")";
		}
		
		for(elementName in _enumNames)
		{
			if(type == elementName)
				return "val_int(" + name + ")"; 
		}
		
		return name;
	}
	
	public function getCppToHaxe(name:String, type:String):String
	{
		type = StringTools.replace(type, "*", "");
		var content:String = "";
	
		switch(type)
		{
			case "CGRect":
				return "cgRectToArray(" + name + ")";
			
			case "CGPoint":
				return "cgPointToArray(" + name + ")";
			
			case "CGSize":
				return "cgSizeToArray(" + name + ")";
			
			case "CGAffineTransform":
				return "cgAffineTransformToArray(" + name + ")";
			
			case "UIColor":
				return "cgColorToArray([" + name + " CGColor])";
			
			case "int":
				return "alloc_int(" + name + ")";
				
			case "NSInteger":
				return "alloc_int(" + name + ")";
			
			case "float":
				return "alloc_float(" + name + ")";
				
			case "CGFloat":
				return "alloc_float(" + name + ")";
				
			case "BOOL":
				return "alloc_bool(" + name + ")";
				
			case "NSString":
				return "alloc_string([" + name + " cStringUsingEncoding:NSUTF8StringEncoding])";
				
			case "UIEdgeInsets":
				return "uiEdgeInsetsToArray(" + name + ")";
		}
		
		
		for(elementName in _enumNames)
		{
			if(type == elementName)
				return "alloc_int(" + name + ")"; 
		}
		
		return name;
	}
	
	public function createStaticMethod(method:Method, clazz, ?overloadNum:Int = 0, ?overrides:Bool=false):Void
	{
		_currentHxClassContent += "static ";
		createMethod(method, clazz, overloadNum, overrides, false);
	}
	
	public function createMethod(method:Method, clazz:Clazz, ?overloadNum:Int = 0, ?overrides:Bool=false, ?addrequire:Bool=true):Void
	{
		if(shouldIgnorType(method.returnType) || method.deprecated)
			return;
	
		if(method.name.indexOf("init") == 0)
			return;
			
		var methodName:String = method.name;
		for(a in 0...method.arguments.length)
		{
			if(method.arguments[a].descriptor != null && method.arguments[a].descriptor != "")
				methodName += method.arguments[a].descriptor.charAt(0).toUpperCase() + method.arguments[a].descriptor.substr(1);
		}
			
		var cppName:String = clazz.name.toLowerCase() + "_" + methodName;
			
		var content:String = "";
		
		content += "\tpublic function " + methodName;
			
		content += "(";
		
		for(a in 0...method.arguments.length)
		{
			var argType:String = getHaxeType(method.arguments[a].type);
			if(shouldIgnorType(argType))
				return;
				
			if(a > 0)
				content += ", ";
				
			if(isUIClass(parser.classes.getClassForType(method.arguments[a].type, false)))
				content += " " + method.arguments[a].name + "Tag:Int";
			else
				content += " " + method.arguments[a].name + ":" + argType;
		}
		
		addTypeUsed(method.returnType);
		content += "):" + getHaxeType(method.returnType) + "\n";
		
		content += "\t{\n";
		content += "\t\t";
		
		if(getHaxeType(method.returnType) != "Void")
			content += "return ";
			
		content += clazz.name.toLowerCase() + "_" + methodName + "(_tag";
		
		for(a in 0...method.arguments.length)
		{
			var argType:String = getHaxeType(method.arguments[a].type);
			content += ", " + method.arguments[a].name;
			
			if(isUIClass(parser.classes.getClassForType(argType, false)))
				content += ".tag";
			
		}
		content += ");\n";
		content += "\t}\n";
		content += "\tprivate static var " +  cppName + " = Lib.load(\"basis\", \"" + cppName + "\", " + Std.string(method.arguments.length + 1)  +  ");\n";
	
		_currentHxClassContent += content;
		
		//---- CPP
		
		_currentCppClassContent += "\t";
		if(getHaxeType(method.returnType) != "Void")
			_currentCppClassContent += "value ";
		else
			_currentCppClassContent += "void ";
			
		_currentCppClassContent += cppName + "(value tag";
		
		for(a in 0...method.arguments.length)
		{
			_currentCppClassContent += ", value arg" + Std.string(a+1);
		}
		
		_currentCppClassContent += ")\n";
		_currentCppClassContent += "\t{\n";
		_currentCppClassContent += "\t\t" + clazz.name + " *view = (" + clazz.name + "*)[[BasisApplication getViewManager] getView:val_int(tag)];\n";
		for(a in 0...method.arguments.length)
		{
			if(isUIClass(parser.classes.getClassForType(getHaxeType(method.arguments[a].type), false)))
			{
				_currentCppClassContent += "\t\t" +  method.arguments[a].type + " carg" + Std.string(a+1) + " = " + "(" + method.arguments[a].type + ")[[BasisApplication getViewManager] getView:val_int(arg" + Std.string(a+1) + ")];\n";
			}
			else
				_currentCppClassContent += "\t\t" +  method.arguments[a].type + " carg" + Std.string(a+1) + " = " + getHaxeToCpp("arg" + Std.string(a+1), method.arguments[a].type) + ";\n";
		}
		
		_currentCppClassContent += "\t\t";
		
		if(getHaxeType(method.returnType) != "Void")
			_currentCppClassContent += method.returnType + " returnVar = ";
		
		_currentCppClassContent += "[view " + method.name;
		
		
		for(a in 0...method.arguments.length)
			_currentCppClassContent += method.arguments[a].descriptor + ":carg" + Std.string(a+1) + " ";
		
		_currentCppClassContent += "];\n";
		
		
		if(getHaxeType(method.returnType) != "Void")
		{
			if(isUIClass(parser.classes.getClassForType(getHaxeType(method.returnType), false)))
				_currentCppClassContent += "\t\treturn alloc_int(returnVar.tag);\n";
			else
				_currentCppClassContent += "\t\treturn " + getCppToHaxe("returnVar", method.returnType) + ";\n";
		}
		
		_currentCppClassContent += "\t}\n";
		
		_currentCppClassContent += "\tDEFINE_PRIM (" + cppName  + ", " + Std.string(method.arguments.length + 1)  + ");\n\n";
		
		
		/*
		void uiview_willRemoveSubview(value tag, value tag1)
		{
			UIView *view = (UIView *)[[BasisApplication getViewManager] getView:val_int(tag)];
			id arg1 = [[BasisApplication getViewManager] getView:val_int(tag1)];
			[view willRemoveSubview:arg1 ];
			
		}
		DEFINE_PRIM (uiview_willRemoveSubview, 2);
*/
		
		
		
		//---------
	}
	
	public function createEnum(enumeration:Enumeration):Void
	{
	
		if(enumeration.name == "{" || enumeration.name == "")
			return;
	
		
		for(a in 0...enumeration.elements.length)
		{
			if( enumeration.elements[a].name.length <= 4)
				return ;
				
			_currentHxClassContent += "\tpublic static inline var " + enumeration.elements[a].name + ":Int = ";
			if(enumeration.elements[a].value == "")
				 _currentHxClassContent += a +";\n";
			else
				_currentHxClassContent += " " + enumeration.elements[a].value +";\n";
		}
		
	}
	
	public function createStructure(structure:Structure, clazz:Clazz):Void
	{
	/*
		if(structure.name.charAt(0) == "_")
			return "";
	
		var contents = "extern class " + structure.name + "\n";
		contents += "{";
		
		contents += "\n\t public function new();";
		
		for(a in 0...structure.properties.length)
		{
			contents += "\n\t " + createProperty(structure.properties[a], clazz);
		}
		
		contents += "\n}";
		*/
	}
	
	public function createConstant(constant:Constant):Void
	{
		_currentHxClassContent += "//static public inline var " + constant.name + ":" + getHaxeType(constant.type) + ";";
		addTypeUsed(constant.type);
	}
	
	
	public function createClassPackage(clazz:Clazz):String
	{
		var packagePath:String = StringTools.replace(clazz.savePath, "/", ".");

		if(packagePath.charAt(0) == ".")
			packagePath = packagePath.substr(1);
			
		return packagePath;
	}
	
	private function isUIClass(clazz:Clazz):Bool
	{
		if(clazz == null)
			return false;
			
		return parser.classes.deosClassExtendFromClass(clazz, "UIView");
	}
	
	public function getHaxeType(objcType:String):String
	{
	
		var type:String = objcType;
		
		if(type.indexOf("const") >= 0)
			type = type.substring(0, type.indexOf("const")) + type.substr(type.indexOf("const") + 5);
		
		
		if(_typeObjToHaxe.exists(type))
			return _typeObjToHaxe.get(type);
			
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
		
		for(elementName in _enumNames)
		{
			if(objcType == elementName)
				return "Int"; 
		}
			
		return type;
	}
	
	private function addTypeUsed(type:String):Void
	{
		type = getHaxeType(type);
	}
	
	private function createTypeConversionHash():Void
	{
		_typeObjToHaxe = new Hash<String>();
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
		_typeObjToHaxe.set("id", "Dynamic");
		_typeObjToHaxe.set("id*", "Dynamic");
		_typeObjToHaxe.set("void*", "Dynamic");
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
		_typeObjToHaxe.set("CGRect", "Array<Float>");
		_typeObjToHaxe.set("CGSize", "Array<Float>");
		_typeObjToHaxe.set("CGPoint", "Array<Float>");
		_typeObjToHaxe.set("CGAffineTransform", "Array<Float>");
		_typeObjToHaxe.set("UIColor", "Array<Float>");
		_typeObjToHaxe.set("UIColor*", "Array<Float>");
		_typeObjToHaxe.set("UIEdgeInsets", "Array<Float>");
		_typeObjToHaxe.set("UIEdgeInsets*", "Array<Float>");
		
		
		
		_typeObjToHaxe.set("NSZone", "Dynamic");
		_typeObjToHaxe.set("NSZone*", "Dynamic");
	}
}