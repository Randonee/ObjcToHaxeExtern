package test.org.objctohaxeextern;


import org.objctohaxeextern.Lexer;

class LexerTester extends haxe.unit.TestCase
{
    public function testEnum():Void
    {
    	var objc:String = "typedef NS_ENUM(NSInteger, UIViewContentMode) {\n\tUIViewAnimationTransitionNone,\n\tUIViewAnimationTransitionFlipFromLeft,\n\tUIViewAnimationTransitionFlipFromRight,\n\tUIViewAnimationTransitionCurlUp,\n\tUIViewAnimationTransitionCurlDown,\n};";
    
    	var lexer:Lexer = new Lexer();
    	var tokens:Array<String> = lexer.createTokens(objc);
    	
    	assertEquals(15, tokens.length);
    	
    	assertEquals("enum", tokens[0]);
    	assertEquals("UIViewContentMode", tokens[1]);
    	
    }
    
    public function testEnumMultiLine():Void
    {
    	var obj:Array<String> = ["typedef NS_ENUM(NSInteger, UIViewContentMode) {\n",
    		"\tUIViewAnimationTransitionNone,\n",
    		"\tUIViewAnimationTransitionFlipFromLeft,\n",
    		"\tUIViewAnimationTransitionFlipFromRight,\n",
    		"\tUIViewAnimationTransitionCurlUp,\n",
    		"\tUIViewAnimationTransitionCurlDown,\n",
    		"};\n"];
    	
    	var lexer:Lexer = new Lexer();
    	var tokens:Array<String> = lexer.createTokens(obj[0]);
    	
    	assertTrue(lexer.instructionSpansToNextLine);
    	var index:Int = 1;
    	while(lexer.instructionSpansToNextLine)
    	{
    		tokens = tokens.concat(lexer.createTokens(obj[index]));
    		++index;
    	}
    	
    	assertEquals(15, tokens.length);
    	
    	assertEquals("enum", tokens[0]);
    	assertEquals("UIViewContentMode", tokens[1]);
    }
    
    public function testEnumComentsAndValues():Void
    {
	    var obj:Array<String> = ["typedef NS_ENUM(NSInteger, UIViewContentMode) {\n",
	    		"\tUIViewAnimationOptionLayoutSubviews            = 1 <<  0,\n",
	    		"\tUIViewAnimationOptionAllowUserInteraction      = 1 <<  1, // turn on user interaction while animating\n",
	    		"\tUIViewAnimationTransitionFlipFromRight,\n",
	    		"\tUIViewAnimationTransitionCurlUp,\n",
	    		"\tUIViewAnimationTransitionCurlDown,\n",
	    		"};\n"];
	    	
    	var lexer:Lexer = new Lexer();
    	var tokens:Array<String> = lexer.createTokens(obj[0]);
    	
    	assertTrue(lexer.instructionSpansToNextLine);
    	var index:Int = 1;
    	while(lexer.instructionSpansToNextLine)
    	{
    		tokens = tokens.concat(lexer.createTokens(obj[index]));
    		++index;
    	}
    	
    	assertEquals(25, tokens.length);
    }
    
    public function testNSAvailableWithMethod():Void
    {
    	var methodStr:String = "- (UIView *)viewForBaselineLayout NS_AVAILABLE_IOS(6_0);";
    	
    	var lexer:Lexer = new Lexer();
    	var tokens:Array<String> = lexer.createTokens(methodStr);
    	
    	assertEquals(7, tokens.length);
    }
    
    public function testRemoveNSAvailables():Void
    {
    	var lexer:Lexer = new Lexer();
    	assertEquals(" @interface", lexer.removeNSAvailables("NS_CLASS_AVAILABLE_IOS(2_0) @interface"));
    	assertEquals(" @interface", lexer.removeNSAvailables("NS_AVAILABLE_IOS(2_asdf0) @interface"));
    }
    
    public function testBlockCommentRemoval():Void
    {
    	var lexer:Lexer = new Lexer();
    	
    	lexer.createTokens("some tokens /* more stuff");
    	lexer.createTokens("some comments");
    	lexer.createTokens("some comments*/");
    	
    	assertEquals(2, lexer.createTokens("1 2").length);
    	
    }
    
    public function testRemoveToEndOfBlockComment():Void
    {
    	var lexer:Lexer = new Lexer();
    	assertEquals("This is it", lexer.removeToEndOfBlockComment("gobble gobble */This is it"));
    }
    
    public function testParseConst():Void
    {
    	var lexer:Lexer = new Lexer();
    	var tokens:Array<String> = lexer.createTokens("UIKIT_EXTERN const CGSize UILayoutFittingExpandedSize NS_AVAILABLE_IOS(6_0);");
    	assertEquals(5, tokens.length);
    	assertEquals("const", tokens[1]);
    }
    
}