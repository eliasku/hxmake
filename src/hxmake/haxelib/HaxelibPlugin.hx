package hxmake.haxelib;

import hxmake.haxelib.HaxelibExt.HaxeLibraryDeclaration;

class HaxelibPlugin extends Plugin {

	public var ext(default, null):HaxelibExt;

	function new() {}

	override function apply(module:Module) {
		ext = module.set("haxelib", new HaxelibExt());
		module.task("haxelib", new HaxelibTask()).dependsOn("haxelibDependencies");
		if(module.parent == null) {
			module.task("haxelibDependencies", new HaxelibDependencies());
		}
	}

	public static function library(module:Module):HaxeLibraryDeclaration {
		module.update("haxelib", function(data:HaxelibExt) {
			data.library = new HaxeLibraryDeclaration();
		});
		return module.get("haxelib", HaxelibExt).library;
	}
}
