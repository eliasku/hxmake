package hxmake.haxelib;

import hxmake.utils.Haxelib;
import hxmake.cli.CL;
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

		if(ext.library != null) {
			if(ext.library.generateJson) {
				saveJson(module);
			}
	
			if(ext.library.devInstall) {
				Haxelib.dev(module.name, module.path);
			}
		}
	}

	function saveJson(module:Module) {
		var config:ModuleConfig = module.config;
		var data:Dynamic = {
			name: module.name,
			description: config.description,
			version: config.version,
			contributors: config.authors
		};

		if(config.dependencies != null) {
			var deps = new Map<String, String>();
			for(k in config.dependencies.keys()) {
				if(k == "hxmake") {
					continue;
				}
				var sections = config.dependencies.get(k).split(";");
				var params = sections.shift();
				if(params == "haxelib") {
					params = "";
				}
				else if(params.indexOf("haxelib:") == 0) {
					params = params.substring("haxelib:".length);
				}
				deps.set(k, params);
			}
			data.dependencies = deps;
		}

		if (config.classPath.length > 0) {
			data.classPath = config.classPath[0];
		}

		var haxelibJsonPath:String = Path.join([module.path, "haxelib.json"]);
		Debug.log("Writing " + haxelibJsonPath);
		File.saveContent(haxelibJsonPath, Json.stringify(data, null, "\t"));
	}
}
