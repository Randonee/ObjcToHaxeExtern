Converts objective c class header files to haxe class externs

Usage

	neko objctohaxeextern.n /path/to/source /path/to/destination

* Parses source directory and sub directories for files ending in ".h"
* Package path for classes is based on source directory structure. Example: source/com/somename/SomeHeader.h would become com.somename.SomeHeader.hx