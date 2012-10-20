package org.objctohaxeextern;

class Lexer
{
	private static inline var opperators:Array<String> = [" ", "*", "(", ")", "/" , "-", "+", "@", "<", ">", '"', "'", "=" ,",", ":", ";", "\n", "\t", "\r"];
	public var instructionSpansToNextLine(default, null):Bool;
	
	private var _inBlockComment:Bool;
	
	public function new()
	{
		_inBlockComment = false;
		instructionSpansToNextLine = false;
	}
	
	public function createTokens(text:String):Array<String>
	{
		//neko.Lib.println("----  " + text);
		
		if(_inBlockComment)
			text = removeToEndOfBlockComment(text);
			
		text = removeNSAvailables(text);
		var tokens:Array<String> = [];
		var a:Int = 0;
		var token:String = "";
		
		
		if(_inBlockComment)
			return tokens;
		
		while(a < text.length)
		{
			var char:String = text.charAt(a);
			
			if(isOpperator(char))
			{
				if(token != "")
				{
					tokens.push(token);
					token = "";
				}
			
				if(char == '"')
				{
					tokens.push('"');
					var token:String = getUntilChar(text, '"', a+1);
					tokens.push(token);
					tokens.push('"');
					a += token.length;
				}
				else if(char == "'")
				{
					tokens.push("'");
					var token:String = getUntilChar(text, "'", a+1);
					tokens.push(token);
					tokens.push("'");
					a += token.length;
				}
			
				else if(char == "/")
				{
					if(charIs(text, "/", a+1))
					{
						//the rest of the line is a comment
						return tokens;
					}
					else if(charIs(text, "*", a+1))
					{
						var more:Bool = true;
						while(a < text.length && more)
						{
							if(containsChar(text, "/", a))
							{
								var comment:String = getUntilChar(text, '/', a+1);
								a += comment.length;
								if(charIs(text, "*", a-1))
									more = false;
							}
							else
								++a;
							
						}
						if(more)
						{
							_inBlockComment = true;
						}
					}
					else
						tokens.push(char);
				}
				else if(char == " " || char == "\n" || char =="\t" || char == "\r")
				{
					//skip
				}
				else
				{
					tokens.push(char);
				}
			}
			else
				token += char;
				
			++a;
		}
		
		if(token != "")
			tokens.push(token);
		
		
		if(tokens[0] == "enum" || ( tokens[0] == "typedef" && ( tokens[1] == "NS_ENUM" || tokens[1] == "NS_OPTIONS") ) )
		{
			//typedef NS_ENUM(NSInteger, UIViewContentMode) {
		
			tokens = tokens.slice(5);
			tokens[1] = tokens[0];
			tokens[0] = "enum";
			
			if(!containsChar(text, "}", 0))
				instructionSpansToNextLine = true;
		}
		else if(instructionSpansToNextLine && containsChar(text, "}", 0))
			instructionSpansToNextLine = false;
			
		return tokens;
	}


	private function isOpperator(opp:String):Bool
	{
		for(a in 0...opperators.length)
		{
			if(opperators[a] == opp)
				return true;
		}
		return false;
	}
	
	private function charIs(text:String, char:String, pos:Int):Bool
	{
		return (pos < text.length && char == text.charAt(pos));
	}
	
	
	private function getUntilChar(text:String, char:String, pos:Int):String
	{
		var a:Int = pos;
		var token:String = "";
		
		while(a < text.length && text.charAt(a) != char)
		{
			token += text.charAt(a);
			++a;
		}
		return token;
	}
	
	private function containsChar(text:String, char:String, pos:Int):Bool
	{
		var a:Int = pos;
		while(a < text.length)
		{
			if(text.charAt(a) == char)
				return true;
			++a;
		}
		return false;
	}
	
	public function removeNSAvailables(str:String):String
	{
		var eReg:EReg = ~/\bNS_AVAILABLE_IOS\b\(.*\)/g;
		str = eReg.replace(str, "");
		 
		eReg = ~/\bNS_CLASS_AVAILABLE_IOS\b\(.*\)/g;
		str = eReg.replace(str, "");
		
		eReg = ~/\bNS_DEPRECATED_IOS\b\(.*\)/g;
		str = eReg.replace(str, "");
		
		return str;
	}
	
	public function removeToEndOfBlockComment(text:String):String
	{
		var a:Int = 0;
		while(a < text.length)
		{
			if(text.charAt(a) == "/" && a > 0 && text.charAt(a-1) == "*")
			{
				_inBlockComment = false;
				if(a < text.length - 2)
					return text.substring(a+1);
				else
					return "";
				
			}
			
			++a;
		}
		
		return "";
	}

}