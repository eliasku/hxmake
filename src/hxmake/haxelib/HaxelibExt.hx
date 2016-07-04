package hxmake.haxelib;

class HaxelibExt {

	public var library:HaxeLibraryDeclaration;

	public function new() {}
}

class HaxeLibraryDeclaration {
	public var generateJson:Bool = true;
	public var devInstall:Bool = true;

	public function new() {}
}