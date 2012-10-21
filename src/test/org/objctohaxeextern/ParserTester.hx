package test.org.objctohaxeextern;


import org.objctohaxeextern.Clazz;
import org.objctohaxeextern.Parser;

class ParserTester extends haxe.unit.TestCase
{
    public function testParseMethod()
    {
    	var clazz:Clazz = new Clazz();
    	var tokens:Array<String> = ["-", "(", "void", ")", "foo", ":", "(", "int", ")", "num", ";"];
    	
    	var parser:Parser = new Parser();
    	
    	parser.parseMethod(tokens, clazz);
    	
    	assertTrue(clazz.methods.exists("foo"));
    	var method:Method = clazz.methods.get("foo")[0];
    	assertEquals("foo", method.name);
    	assertEquals("num", method.arguments[0].name);
    	assertEquals("int", method.arguments[0].type);
    	assertEquals("void", method.returnType);
    	
    	
    	clazz = new Clazz();
    	tokens = ["-", "(", "UILabel" ,"*", ")", "foo", ":", "(", "UIView", "*", ")", "view", "withInt", ":", "(", "unsigned", "int", ")", "num", ";"];
    	
    	parser.parseMethod(tokens, clazz);
    	
    	assertTrue(clazz.methods.exists("foo"));
    	var method:Method = clazz.methods.get("foo")[0];
    	assertEquals("foo", method.name);
    	assertEquals("view", method.arguments[0].name);
    	assertEquals("UIView*", method.arguments[0].type);
    	assertEquals("num", method.arguments[1].name);
    	assertEquals("unsignedint", method.arguments[1].type);
    	assertEquals("UILabel*", method.returnType);
    }
    
    
    public function testMethodParser2():Void
    {
    	//- (UIView *)viewForBaselineLayout ;
    	var tokens:Array<String> = ["-", "(", "UIView", "*", ")", "viewForBaselineLayout",";"];
    	
    	var clazz:Clazz = new Clazz();
    	
    	var parser:Parser = new Parser();
    	
    	parser.parseMethod(tokens, clazz);
    	
    	assertTrue(clazz.methods.exists("viewForBaselineLayout"));
    	var method:Method = clazz.methods.get("viewForBaselineLayout")[0];
    	assertEquals("viewForBaselineLayout", method.name);
    	assertEquals("UIView*", method.returnType);
    }
    
    public function testParseStaticMethod()
    {
    	var clazz:Clazz = new Clazz();
    	var tokens:Array<String> = ["+", "(", "void", ")", "foo", ":", "(", "int", ")", "num", ";"];
    	
    	var parser:Parser = new Parser();
    	
    	parser.parseMethod(tokens, clazz);
    	
    	var method:Method = clazz.staticMethods[0];
    	assertEquals("foo", method.name);
    	assertEquals("num", method.arguments[0].name);
    	assertEquals("int", method.arguments[0].type);
    	assertEquals("void", method.returnType);
    }
    
    public function testParseProperty()
    {
    	var clazz:Clazz = new Clazz();
    	var tokens:Array<String> = ["@", "property", "(", "readonly", ")", "int", "num", ";"];
    	
    	var parser:Parser = new Parser();
    	
    	parser.parseProperty(tokens, clazz);
    	
    	var property:Property = clazz.properties[0];
    	assertEquals("num", property.name);
    	assertEquals("int", property.type);
    	assertTrue(property.readOnly);
    }
    
    public function testParseClassDefinition()
    {
    	var clazz:Clazz = new Clazz();
    	var tokens:Array<String> = ["@", "interface", "SomeClass", ":", "ParentClass", "<", "protocol1", ",", "protocol2", ">", ";"];
    	
    	var parser:Parser = new Parser();
    	
    	parser.parseClassDefinition(tokens, clazz);
    	
    	assertEquals("SomeClass", clazz.name);
    	assertEquals("ParentClass", clazz.parentClassName);
    	assertEquals("protocol1", clazz.protocols[0]);
    	assertEquals("protocol2", clazz.protocols[1]);
    }
    
    
    public function testEnumeration()
    {
    	var clazz:Clazz = new Clazz();
    	var tokens:Array<String> = ["enum", "SomeEnum", "{", "val1", ",", "val2", ",", "val3", "}"];
    	
    	var parser:Parser = new Parser();
    	
    	parser.parseEnum(tokens, clazz);
    	
    	assertEquals("SomeEnum", clazz.enumerations[0].name);
    	assertEquals(3, clazz.enumerations[0].elements.length);
    	assertEquals("val1", clazz.enumerations[0].elements[0]);
    	assertEquals("val2", clazz.enumerations[0].elements[1]);
    	assertEquals("val3", clazz.enumerations[0].elements[2]);
    	
    	
    	
    	clazz = new Clazz();
    	tokens = ["enum", "SomeEnum", "{", "val1", "=", "<", "<", "1", ",", "val2", ",", "val3", ",", "}"];
    	
    	parser = new Parser();
    	parser.parseEnum(tokens, clazz);
    	
    	assertEquals("SomeEnum", clazz.enumerations[0].name);
    	assertEquals(3, clazz.enumerations[0].elements.length);
    	assertEquals("val1", clazz.enumerations[0].elements[0]);
    	assertEquals("val2", clazz.enumerations[0].elements[1]);
    	assertEquals("val3", clazz.enumerations[0].elements[2]);
    	
    	
    	clazz = new Clazz();
    	tokens = ["enum", "SomeEnum", "{", "val1", ",", "val2", ",", "val3", "=", "<", "<", "1",  "}"];
    	
    	parser = new Parser();
    	parser.parseEnum(tokens, clazz);
    	
    	assertEquals("SomeEnum", clazz.enumerations[0].name);
    	assertEquals(3, clazz.enumerations[0].elements.length);
    	assertEquals("val1", clazz.enumerations[0].elements[0]);
    	assertEquals("val2", clazz.enumerations[0].elements[1]);
    	assertEquals("val3", clazz.enumerations[0].elements[2]);
    }
    
}