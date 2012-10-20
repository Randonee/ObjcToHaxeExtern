package test.org.objctohaxeextern;

import org.objctohaxeextern.ClassCollection;
import org.objctohaxeextern.Clazz;

class ClassCollectionTester extends haxe.unit.TestCase
{
    public function testExportOverride()
    {
    	var classes:ClassCollection = new ClassCollection();
    	for(a in 0...5)
    	{
    		var clazz:Clazz = new Clazz();
    		clazz.name = "Class" + a;
    		clazz.addMethod({name:"foo" + a, arguments:new Array<Argument>(), returnType:"int"});
    		
    		if(a > 1)
    			clazz.parentClassName = "Class" + Std.string(a - 1);
    			
    		classes.addClass(clazz);
    	}
    	
    	var searchClass:Clazz = classes.items.get("Class4");
    	assertTrue(classes.isMothodDefinedInSuperClass("foo1", searchClass) );
    	
    }
    
}