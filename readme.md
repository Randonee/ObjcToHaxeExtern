Converts objective c header files into usable files for these projects:

* https://github.com/Randonee/BasisApple
* https://github.com/ralcr/haxe-objective-c-target

Usage

* For basis use: neko objctohaxeextern.n /path/to/source /path/to/destination basis
* for objc-target use: neko objctohaxeextern.n /path/to/source /path/to/destination objc

Info

* Parses source directory and sub directories for files ending in ".h"
* Package path for classes is based on source directory structure. Example: source/com/somename/SomeHeader.h would become com.somename.SomeHeader.hx
* You can find ios header files at: /Applications/xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS6.1.sdk/System/Library/Frameworks