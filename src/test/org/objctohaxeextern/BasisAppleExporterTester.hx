package test.org.objctohaxeextern;


import org.objctohaxeextern.BasisAppleExporter;

class BasisAppleExporterTester extends haxe.unit.TestCase
{
    public function testFieldExistsInString()
    {
    	var str:String = "static public function initWithStyleReuseIdentifier( style:Int,  reuseIdentifier:String):Dynamic";
    	var exporter:BasisAppleExporter = new BasisAppleExporter(null);
    
    	assertTrue(exporter.fieldExistsInString(str, "initWithStyleReuseIdentifier"));
    }
    
    
}