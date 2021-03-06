package test.org.objctohaxeextern;


import org.objctohaxeextern.Clazz;
import org.objctohaxeextern.Parser;
import org.objctohaxeextern.ExternExporter;

class ExternExporterTester extends haxe.unit.TestCase
{
    public function testExportOverride()
    {
    	var exporter:ExternExporter = new ExternExporter(new Parser());
    	var method:Method = {name:"foo", arguments:new Array<Argument>(), returnType:"int", deprecated:false, sdk:""};
    	
    	assertEquals("public override function foo():Int;", exporter.createMethod(method, 0, true) );
    }
    
}