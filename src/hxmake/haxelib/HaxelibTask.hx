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
		validateDependencies(config);
		var json:Dynamic = Json.stringify(config.toDynamic(), null, '\t');
		var path:String = Path.join([module.path, "haxelib.json"]);
		Log.info('Writing $path ...');
		File.saveContent(path, json);
	}

	function validateDependencies(config:LibraryConfig):Void {
		var dependencies:Map<String, String> = config.dependencies;

		if (dependencies == null) {
			return;
		}

		for (libraryName in dependencies.keys()) {
			var libraryVersion:String = dependencies.get(libraryName);

			if (libraryVersion == null || libraryVersion == "") {
				continue;
			}

			if (libraryVersion.indexOf("hg:") == 0) {
				Log.warning('haxelib.json generating: ${module.name} has a mercurial dependency ${libraryName} which is not supported by haxelib.json.');
			} else if (libraryVersion.indexOf("git:") == 0) {
				var gitSettings:Array<String> = libraryVersion.split("#");
				if (gitSettings.length > 2) {
					Log.warning('haxelib.json generating: ${module.name} has a git dependency ${libraryName} with specified sub directory or version which are not supported by haxelib.json.');
				}
			}
		}
	}
}
