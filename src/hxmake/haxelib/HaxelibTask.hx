package hxmake.haxelib;

import haxe.io.Path;
import haxe.Json;
import hxmake.haxelib.HaxelibPlugin;
import hxmake.utils.Haxelib;
import sys.io.File;

using StringTools;

class HaxelibTask extends Task {

	public function new() {
		description = "Prepare module for usage via haxelib";
	}

	override public function run() {
		var ext:HaxelibConfig = module.getExtConfig("haxelib");

		if (ext.updateJson) {
			saveHaxelibJson(ext);
		}

		if (ext.installDev) {
			Haxelib.dev(getName(ext), module.path);
		}
	}

	function saveHaxelibJson(config:HaxelibConfig) {
		validateDependencies();
		var jsonData = genHaxelibJson(config);
		var json:String = Json.stringify(jsonData, null, '\t');
		var path:String = Path.join([module.path, "haxelib.json"]);
		project.logger.info('Writing $path ...');
		File.saveContent(path, json);
	}

	function getName(config:HaxelibConfig) {
		return config.name != null ? config.name : module.name;
	}

	function genHaxelibJson(config:HaxelibConfig):Dynamic {
		var data:Dynamic = {
			name: getName(config),
			description: config.description,
			version: config.version
		};

		if (config.contributors != null && config.contributors.length > 0) {
			data.contributors = config.contributors;
		}

		if (config.license != null) {
			data.license = config.license;
		}

		if (config.url != null) {
			data.url = config.url;
		}

		if (config.tags != null && config.tags.length > 0) {
			data.tags = config.tags;
		}

		if (config.releasenote != null) {
			data.releasenote = config.releasenote;
		}

		var cp = module.config.classPath;
		if (cp != null && cp.length > 0) {
			data.classPath = cp[0];
		}

		var deps = module.config.dependencies;
		for (k in deps.keys()) {
			data.dependencies = deps;
			break;
		}

		return data;
	}

	function validateDependencies():Void {
		var dependencies:Map<String, String> = HaxelibPlugin.readDependencies(module);

		if (dependencies == null) {
			return;
		}

		for (libraryName in dependencies.keys()) {
			var libraryVersion:String = dependencies.get(libraryName);

			if (libraryVersion == null || libraryVersion == "") {
				continue;
			}

			if (libraryVersion.indexOf("hg:") == 0) {
				project.logger.warning('haxelib.json generating: ${module.name} has a mercurial dependency ${libraryName} which is not supported by haxelib.json.');
			} else if (libraryVersion.indexOf("git:") == 0) {
				var gitSettings:Array<String> = libraryVersion.split("#");
				if (gitSettings.length > 2) {
					project.logger.warning('haxelib.json generating: ${module.name} has a git dependency ${libraryName} with specified sub directory or version which are not supported by haxelib.json.');
				}
			}
		}
	}
}
