package hxmake.haxelib;

class HaxelibExt {

	// for generating haxelib.json
	public var config(default, null):LibraryConfig = new LibraryConfig();

	public var updateJson:Bool = false;
	public var installDev:Bool = false;

	public function new() {}
}