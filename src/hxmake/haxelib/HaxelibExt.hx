package hxmake.haxelib;

class HaxelibExt {

	// for generating haxelib.json
	public var config(default, null):LibraryConfig = new LibraryConfig();
	public var pack(default, null):LibraryPackage = new LibraryPackage();

	public var updateJson:Bool = false;
	public var installDev:Bool = false;

	public function new() {}
}