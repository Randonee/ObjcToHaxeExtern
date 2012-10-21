package test.org.objctohaxeextern;

import uikit.UIView;

class TestMain
{
    static function main()
    {
        var r = new haxe.unit.TestRunner();
        r.add(new ParserTester());
        r.add(new LexerTester());
        r.add(new ExternExporterTester());
        r.add(new ClassCollectionTester());
        r.run();
        
        new UIView();
    }
}