Converts Apple objective c class header files to haxe class externs. This app was created to convert apple header files into haxe externs used by https://github.com/ralcr/haxe-objective-c-target

Usage

	neko objctohaxeextern.n /path/to/source /path/to/destination

* Parses source directory and sub directories for files ending in ".h"
* Package path for classes is based on source directory structure. Example: source/com/somename/SomeHeader.h would become com.somename.SomeHeader.hx