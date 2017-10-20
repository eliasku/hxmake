package hxmake.haxelib;

import hxmake.utils.Haxelib;

class HaxelibSubmitTask extends Task {

	public function new() {
		description = "Submit haxe library package";
	}

	override public function run() {
		var ext:HaxelibExt = module.get("haxelib", HaxelibExt);

		if (ext == null || !module.isActive) {
			return;
		}

		var config = ext.config;
		if (config.license == null || config.license.length == 0) {
			project.logger.info('Haxelib: missing license value');
			return;
		}

		if (config.releasenote == null || config.releasenote.length == 0) {
			project.logger.info('Haxelib: missing releasenote value');
			return;
		}

		var zipName = module.name + ".zip";
		Haxelib.submit(zipName);
	}
}