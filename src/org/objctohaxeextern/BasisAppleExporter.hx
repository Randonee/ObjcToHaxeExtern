package org.objctohaxeextern;

import org.objctohaxeextern.Clazz;
import org.objctohaxeextern.Parser;

import sys.FileSystem;
import sys.io.File;
import sys.io.FileOutput;

class BasisAppleExporter
{
	private static inline function TYPES_TO_IGNORE():Array<String>{
																return ["CALayer", "NSCoder", "Void", "NSArray", "NSLayoutConstraint", 
																"UIGestureRecognizer", "UIEvent", "NSAttributedString", "UIStoryboard", "UIStoryboardSegue",
																"SEL", "NSSet", "UIViewController", "UIScreen", "NSBundle", "UILocalNotification", "UIBackgroundTaskIdentifier",
																"NSUndoManager", "NSDictionary", "UIPanGestureRecognizer",
																"UIPinchGestureRecognizer", "NSData", "UITextField", "Class", "UINib",
																"UICollectionViewLayout", "UICollectionViewLayoutAttributes",
																"NSLocale", "NSCalendar", "NSTimeZone", "NSDate", "UITabBarItem"];}
																
	private static inline function RETURN_TYPES_TO_IGNORE():Array<String>{return ["UIImage"];}
																

	public var parser(default, null):Parser;
	private var _typesUsed:Map<String, Bool>;
	private var _typeObjToHaxe:Map<String, String>;
	private var _protocolMethods:Array<Method>;
	private var _protocolProperties:Array<Property>;
	private var _methodsWritten:Map<String, Bool>;
	private var _currentClassAdditionContent:String;
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
		_enumNames.push("NSTextAlignment");
		_enumNames.push("NSWritingDirection");
		_enumNames.push("NSTextTabType");
		_enumNames.push("NSLineBreakMode");
		_enumNames.push("UIBaselineAdjustment");
		_enumNames.push("UIBarStyle");
		_enumNames.push("UIDataDetectorTypes");
		_enumNames.push("UIBarMetrics");
		_enumNames.push("UIPopoverArrowDirection");
		_enumNames.push("UITextAutocapitalizationType");
		_enumNames.push("UITextAutocorrectionType");
		_enumNames.push("UITextSpellCheckingType");
		_enumNames.push("UIKeyboardType");
		_enumNames.push("UIInterfaceOrientation");
		
		var hxSavePath:String = "";
		for(clazz in parser.classes.items)
		{
			_currentHxClassContent = "";
			if(! clazz.isProtocol)
			{
				neko.Lib.println("Export " + clazz.name);
				
				hxSavePath = destinationDirectory + "/hx/" + clazz.savePath + "/" + clazz.name + ".hx";
				Util.createDirectory(destinationDirectory + "/hx/" + clazz.savePath + "/");
				
				createClass(clazz);
				
				if(hxSavePath != "" && clazz.savePath != "")
				{
					saveClass(hxSavePath, _currentHxClassContent);
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
		// The UITextInputTraits protocal is implemented in a strange way so its properties need to be added manually to classes.
		if(clazz.tokenExists("UITextInputTraits"))
		{
			var traitClass:Clazz = parser.classes.getClassForType("UITextInputTraits");
			for(property in traitClass.properties)
				clazz.properties.push(property);
		}
			
	
		var packagePath:String = "";
		_typesUsed = new Map<String, Bool>();
	
		packagePath = createClassPackage(clazz);
		
		_currentHxClassContent += "//This code was generated using ObjcToHaxeExtern\n";
		_currentHxClassContent += "//https:/github.com/Randonee/ObjcToHaxeExtern\n\n";
		
		_currentHxClassContent += "package " + packagePath + ";\n\n";
		_currentHxClassContent += "import cpp.Lib;\n";
		_currentHxClassContent += "import basis.object.*;\n";
		_currentHxClassContent += "import apple.appkit.*;\n";
		_currentHxClassContent += "import apple.ui.*;\n";
		_currentHxClassContent += "import basis.BasisApplication;\n";
		_currentHxClassContent += "import basis.object.TypeValues;\n";
		_currentHxClassContent += "\n";
		
		createActuallClass(clazz);
		
		for(subClass in clazz.classesInSameFile)
		{
			if(subClass.parentClassName != "" && subClass.name.toLowerCase().indexOf("delegate") == -1 && !parser.classes.items.exists(subClass.name))
			{
				trace(subClass.name);
				createActuallClass(subClass);
			}
		}
	}
	
	private function createActuallClass(clazz:Clazz):Void
	{
		_protocolMethods = [];
		_protocolProperties = [];
		_methodsWritten = new Map<String, Bool>();
	
		if(clazz.name == "NSMutableArray")
		 return;
	
		if(clazz.hasDefinition)
		{
			createClassDefinition(clazz);
			_currentHxClassContent += "\n{\n";
			
			_currentClassAdditionContent = "";
			var additionsFilePath:String = "additions/" + clazz.savePath + "/" + clazz.name + ".hx";
			if(FileSystem.exists(additionsFilePath))
			{
				_currentHxClassContent += "\n\t//Additions\n";
				_currentClassAdditionContent = File.getContent(additionsFilePath);
				_currentHxClassContent += _currentClassAdditionContent;
				_currentHxClassContent += "\n\t//Additions\n";
			}
			
			
			if(!fieldExistsInString(_currentClassAdditionContent, "function new"))
			{
				_currentHxClassContent += "\n\tpublic function new(?type:Class<IObject>=null)\n";
				_currentHxClassContent += "\t{\n";
				_currentHxClassContent += "\t\tif(type == null)\n";
				_currentHxClassContent += "\t\t\ttype = " + clazz.name  + ";\n";
				_currentHxClassContent += "\t\tsuper(type);\n";
				_currentHxClassContent += "\t}\n";
			}
			
			_currentHxClassContent += "\n\t//Constants\n";
			for(a in 0...clazz.constants.length)
			{
				_currentHxClassContent += "\t";
				createConstant(clazz.constants[a]);
				_currentHxClassContent += "\n";
			}
			
			_currentHxClassContent += "\n\t//Static Methods\n";
			for(methods in clazz.staticMethods)
			{
				for(a in 0...methods.length)
					createStaticMethod(methods[a], clazz) + "\n";
			}
		
			_currentHxClassContent += "\n\t//Properties\n";
			for(a in 0...clazz.properties.length)
			{
				createProperty(clazz.properties[a], clazz) + "\n";
			}
				
			_currentHxClassContent += "\n\t//Methods\n";
			for(methods in clazz.methods)
			{
				for(a in 0...methods.length)
					createMethod(methods[a], clazz, a, parser.classes.isMothodDefinedInSuperClass(methods[a].name, clazz)) + "\n";
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
		
		for(a in 0...clazz.structures.length)
			createStructure(clazz.structures[a], clazz);
			
		_currentHxClassContent += "}\n\n";
	}
	
	
	public function createClassDefinition(clazz:Clazz):Void
	{
		_currentHxClassContent += "class " + clazz.name;
		
		_currentHxClassContent += " extends ";
		if(clazz.parentClassName == "NSObject")
			_currentHxClassContent += "AbstractObject";
		else
			_currentHxClassContent +=  clazz.parentClassName;
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
		if(shouldIgnorType(property.type) || property.deprecated || parser.classes.isPropertyDefinedInSuperClass(property.name, clazz))
			return;
			
		if(fieldExistsInString(_currentClassAdditionContent, property.name))
			return;
			
		var propNameUpper:String = property.name.charAt(0).toUpperCase() + property.name.substring(1);
		var cppGetName:String = clazz.name.toLowerCase() + "_get" + propNameUpper;
		var cppSetName:String = clazz.name.toLowerCase() + "_set" + propNameUpper;
		var argType:String = getHaxeType(property.type);
	
			_currentHxClassContent += "\tpublic var " + property.name + "(";
			
			if(shouldIgnorReturnType(property.type))
				_currentHxClassContent += "null, ";
			else
				_currentHxClassContent += "get_" + property.name + ", ";
				
			if(property.readOnly)
				_currentHxClassContent += "null)";
			else
				_currentHxClassContent += "set_" + property.name + ")";
				
			_currentHxClassContent += ":" + argType + ";\n";
			
			
		if(!shouldIgnorReturnType(property.type))
		{	
			_currentHxClassContent += "\tprivate function get_" + property.name + "():" + argType + "\n";
			_currentHxClassContent += "\t{\n";
			_currentHxClassContent += "\t\treturn BasisApplication.instance.objectManager.callInstanceMethod(this, \"" + property.getterName +"\", [], [], " + convertToCFFIType(property.type) + ");\n";
			_currentHxClassContent += "\t}\n";
		}
		
		if(!property.readOnly)
		{
			_currentHxClassContent += "\n";
			_currentHxClassContent += "\tprivate function set_" + property.name + "(value:" + argType + "):" + argType + "\n";
			_currentHxClassContent += "\t{\n";
			
			var setterName:String = "set" + propNameUpper;
			if(property.name != property.setterName)
				setterName = property.setterName;
			
			_currentHxClassContent += "\t\tBasisApplication.instance.objectManager.callInstanceMethod(this, \"" + setterName +":\", [value], [" +  convertToCFFIType(property.type) +"], -1 );\n";
			if(!shouldIgnorReturnType(property.type))
				_currentHxClassContent += "\t\treturn " + property.name + ";\n";
			else
				_currentHxClassContent += "\t\treturn null;\n";
			
			
			_currentHxClassContent += "\t}\n";
		}
		_currentHxClassContent += "\n";
	}
	
	public function shouldIgnorType(type:String):Bool
	{
		type = StringTools.replace(type, "*", "");
		for(a in 0...TYPES_TO_IGNORE().length)
		{
			if(type == TYPES_TO_IGNORE()[a])
				return true;
		}
		
		return false;
	}
	
	public function shouldIgnorReturnType(type:String):Bool
	{
		type = StringTools.replace(type, "*", "");
		for(a in 0...RETURN_TYPES_TO_IGNORE().length)
		{
			if(type == RETURN_TYPES_TO_IGNORE()[a])
				return true;
		}
		
		return false;
	}
	
	
	public function createStaticMethod(method:Method, clazz, ?overloadNum:Int = 0, ?overrides:Bool=false):Void
	{
		createMethod(method, clazz, overloadNum, overrides, false, true);
	}
	
	
	public function createMethod(method:Method, clazz:Clazz, ?overloadNum:Int = 0, ?overrides:Bool=false, ?addrequire:Bool=true, ?isStatic:Bool=false):Void
	{
		if(shouldIgnorType(method.returnType) || shouldIgnorReturnType(method.returnType) || method.deprecated || parser.classes.isMothodDefinedInSuperClass(method.name, clazz))
			return;
		
		if(method.name == "init")
			return;
		
		var content:String = "\t";
		if(isStatic)
			content += "static ";
			
		var selector:String = "";
			
		var methodName:String = method.name;
		for(a in 0...method.arguments.length)
		{
			if(method.arguments[a].descriptor != null && method.arguments[a].descriptor != "")
			{
				methodName += method.arguments[a].descriptor.charAt(0).toUpperCase() + method.arguments[a].descriptor.substr(1);
				selector += method.arguments[a].descriptor;
			}
			selector += ":";
		}
		
		if(fieldExistsInString(_currentClassAdditionContent, methodName))
			return;
			
		var cppName:String = clazz.name.toLowerCase() + "_" + methodName;
		
		content += "public function " + methodName;
		content += "(";
		
		var argString:String = "";
		var argTypes:String = "";
		for(a in 0...method.arguments.length)
		{
			var argType:String = getHaxeType(method.arguments[a].type);
			if(shouldIgnorType(argType))
				return;
				
			if(a > 0)
			{
				argString += ", ";
				argTypes += ", ";
				content += ", ";
			}
			
			argTypes += convertToCFFIType(method.arguments[a].type) + "";
			
			argString += method.arguments[a].name;
			content += " " + method.arguments[a].name + ":" + argType;
		}
		
		addTypeUsed(method.returnType);
		
		var returnType:String = getHaxeType(method.returnType);
		
		content += "):" + returnType + "\n";
		content += "\t{\n";
		content += "\t\t";
		
		var cffiReturn:String = "-1";
		
		if(getHaxeType(method.returnType) != "Void")
		{
			content += "return ";
			cffiReturn = convertToCFFIType(method.returnType);
		}
		
		if(isStatic)
			content += "BasisApplication.instance.objectManager.callClassMethod(\"" + createClassPackage(clazz) + "." + clazz.name + "\", \"" + method.name + selector + "\", [" + argString +"], [" +  argTypes + "], " + cffiReturn + ");\n";
		else	
			content += "BasisApplication.instance.objectManager.callInstanceMethod(this, \"" + method.name + selector + "\", [" + argString +"], [" +  argTypes + "], " + cffiReturn + ");\n";
		
		content += "\t}\n";
		_currentHxClassContent += content;
	}
	
	public function createEnum(enumeration:Enumeration):Void
	{
		if(enumeration.name == "{" || enumeration.name == "")
			return;
	
		
		for(a in 0...enumeration.elements.length)
		{
			if( enumeration.elements[a].name.length <= 4)
				return ;
				
			var enumValue:String = StringTools.replace(enumeration.elements[a].value, "UL", "");
				
			_currentHxClassContent += "\tpublic static inline var " + enumeration.elements[a].name + ":Int = ";
			if(enumeration.elements[a].value == "")
				 _currentHxClassContent += a +";\n";
			else
				_currentHxClassContent += " " + enumValue +";\n";
		}
		
	}
	
	public function createStructure(structure:Structure, clazz:Clazz):Void
	{
	}
	
	public function createConstant(constant:Constant):Void
	{
		_currentHxClassContent += "//static public inline function " + constant.name + "():" + getHaxeType(constant.type) + "{}";
		addTypeUsed(constant.type);
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
	
	public function fieldExistsInString(str:String, field:String):Bool
	{
		var index:Int = str.indexOf(field + "(");
		
		if(index == -1)
			return false;
		
		if(index > 0 && str.charAt(index-1) != " " )
			return false;
		
		return true;
	}
	
	private function addTypeUsed(type:String):Void
	{
		type = getHaxeType(type);
	}
	
	
	private function convertToCFFIType(type:String):String
	{
		type = StringTools.replace(type, "*", "");
		var newType:String = type;
		
		if(type != "NSURLRequest" && type != "NSURL" && type != "NSIndexPath"  && type != "NSIndexSet"   && type != "UIImage" && type != "UIColor") 
			newType = getHaxeType(type);
		
		if(newType != "Array<Float>" && newType != "Array<int>")
			type = newType;
			
		var cffiType = "TypeValues.";
			
		switch(type)
		{
			case "bool":
				cffiType += "BoolVal";
				
			case "Bool":
				cffiType += "BoolVal";
				
			case "BOOL":
				cffiType += "BoolVal";
				
			case "Int":
				cffiType += "IntVal";
				
			case "Float":
				cffiType += "FloatVal";
				
			case "String":
				cffiType += "StringVal";
				
			case "CGRect":
				cffiType += "CGRectVal";
				
			case "UIEdgeInsets":
				cffiType += "UIEdgeInsetsVal";
				
			case "CGAffineTransform":
				cffiType += "CGAffineTransformVal";

			case "CGPoint":
				cffiType += "CGPointVal";

			case "CGSize":
				cffiType += "CGSizeVal";

			case "CGColorRef":
			case "CGColor":
				cffiType += "CGColorRefVal";

			case "NSURL":
				cffiType += "NSURLVal";
				
			case "NSURLRequest":
				cffiType += "NSURLRequestVal";

			case "NSIndexPath":
				cffiType += "NSIndexPathVal";

			case "NSIndexSet":
				cffiType += "NSIndexSetVal";

			case "NSRange":
				cffiType += "NSRangeVal";

			case "UIOffset":
				cffiType += "UIOffsetVal";
				
			case "UIImage":
				cffiType += "UIImageVal";
				
			case "UIColor":
				cffiType += "UIColorVal";
				
			case "UIFont":
				cffiType += "UIFontVal";
				
			default:
				cffiType += "ObjectVal";
		}
		
		return cffiType;
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
		_typeObjToHaxe.set("CGFloat", "Float");
		_typeObjToHaxe.set("CGFloat*", "Float");
		_typeObjToHaxe.set("double", "Float");
		_typeObjToHaxe.set("CFTimeInterval", "Float");
		_typeObjToHaxe.set("CFTimeInterval*", "Float");
		_typeObjToHaxe.set("unsignedlong", "Float");
		_typeObjToHaxe.set("unsignedlong*", "Float");
		_typeObjToHaxe.set("UIWindowLevel", "Float");
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
		_typeObjToHaxe.set("NSURL*", "String");
		_typeObjToHaxe.set("NSURL", "String");
		_typeObjToHaxe.set("NSURLRequest", "String");
		_typeObjToHaxe.set("NSURLRequest*", "String");
		_typeObjToHaxe.set("NSIndexPath*", "Array<Int>");
		_typeObjToHaxe.set("NSIndexPath", "Array<Int>");
		_typeObjToHaxe.set("NSIndexSet*", "Array<Int>");
		_typeObjToHaxe.set("NSIndexSet", "Array<Int>");
		_typeObjToHaxe.set("UIOffset", "Array<Int>");
		_typeObjToHaxe.set("NSRange", "Array<Int>");
		_typeObjToHaxe.set("UIImage", "String");
		_typeObjToHaxe.set("UIImage*", "String");
		
		
		_typeObjToHaxe.set("NSZone", "Dynamic");
		_typeObjToHaxe.set("NSZone*", "Dynamic");
	}
}