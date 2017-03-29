package hxmake.haxelib;

import haxe.Json;
import haxe.io.Path;
import hxlog.Log;
import hxmake.utils.Haxelib;
import sys.io.File;

using StringTools;

class HaxelibTask extends Task {

	public function new() {
		description = "Prepare module for usage via haxelib";
	}

	override public function run() {
		var ext:HaxelibExt = module.get("haxelib", HaxelibExt);

		if (ext.updateJson) {
			saveHaxelibJson(ext.config);
		}

		if (ext.installDev) {
			if(ext.config.name == null) {
				ext.config.name = module.name;
			}
			Haxelib.dev(ext.config.name, module.path);
		}
	}

	function saveHaxelibJson(config:LibraryConfig) {
		var json:Dynamic = Json.stringify(config.toDynamic(), null, '\t');
		var path:String = Path.join([module.path, "haxelib.json"]);
		Log.info('Writing $path ...');
		File.saveContent(path, json);
	}
}
