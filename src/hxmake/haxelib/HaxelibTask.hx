package hxmake.haxelib;

import hxmake.utils.Haxelib;
import hxmake.cli.Debug;
import haxe.Json;
import sys.io.File;
import haxe.io.Path;

using StringTools;

class HaxelibTask extends Task {

	public function new() {
		description = "Prepare module for usage via haxelib";
	}

	override public function run() {
		var ext:HaxelibExt = module.get("haxelib", HaxelibExt);

		if(ext.updateJson) {
			saveHaxelibJson(ext.config);
		}

		if(ext.installDev) {
			Haxelib.dev(ext.config.name, module.path);
		}
	}

	function saveHaxelibJson(config:LibraryConfig) {
		var json:Dynamic = Json.stringify(config.toDynamic(), null, '\t');
		var path:String = Path.join([module.path, "haxelib.json"]);
		Debug.log('Writing $path ...');
		File.saveContent(path, json);
	}
}
