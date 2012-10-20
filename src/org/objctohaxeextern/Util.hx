package org.objctohaxeextern;

import sys.FileSystem;
import sys.io.File;

class Util
{
	static public function deleteDirectory(path:String):Void
	{
		if(FileSystem.exists(path) && FileSystem.isDirectory(path))
		{
			var files:Array<String> = FileSystem.readDirectory(path);
			for(a in 0...files.length)
			{
				if(FileSystem.isDirectory(path + "/" + files[a]))
					deleteDirectory(path + "/" + files[a]);
				else
					FileSystem.deleteFile(path + "/" + files[a]);
			}
			
			FileSystem.deleteDirectory(path);
		}
	}
	
	static public function createDirectory(path:String):Void
	{
		var parts:Array<String> = path.split("/");
		var tempPath:String = "";
		
		if(path.charAt(0) == "/")
			tempPath += "/";
		
		for(a in 0...parts.length)
		{
			if(parts[a] != "")
			{
				tempPath += parts[a] + "/";
				if(!FileSystem.exists(tempPath))
				{
					FileSystem.createDirectory(tempPath);
				}
			}
		}
	}

}