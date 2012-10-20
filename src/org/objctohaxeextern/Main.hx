package org.objctohaxeextern;


import sys.FileSystem;
import sys.io.File;

import neko.Lib;


class Main
{

	static public var headers:String;

	public static function main()
	{
		if(Sys.args().length != 2 || Sys.args()[0] == "help" || Sys.args()[0] == "?")
		{
			Lib.println("Parses souce directory and sub directories for files ending in \".h\"");
			Lib.println("Package path is based on source directory structure.");
			Lib.println("Example: source/com/somename/SomeHeader.h would become com.somename.SomeHeader.hx");
			Lib.println(" Usage : neko objctohaxeextern.n /path/to/source /path/to/destination");
		}
		else
		{
			var parser:Parser = new Parser();
			parser.parseDirectory(Sys.args()[0]);
			
			var externExporter:ExternExporter = new ExternExporter(parser);
			externExporter.export(Sys.args()[1]);
		}
	}
	
	
}