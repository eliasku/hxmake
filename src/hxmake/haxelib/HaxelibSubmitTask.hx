package hxmake.haxelib;

import hxmake.utils.Haxelib;

class HaxelibSubmitTask extends Task {

	public function new() {
		description = "Submit haxe library package";
	}

	override public function run() {
		var ext:HaxelibConfig = module.getExtConfig("haxelib");

		if (ext == null || !module.isActive) {
			return;
		}

		if (ext.license == null || ext.license.length == 0) {
			project.logger.info('Haxelib: missing license value');
			return;
		}

		if (ext.releasenote == null || ext.releasenote.length == 0) {
			project.logger.info('Haxelib: missing releasenote value');
			return;
		}

		var zipName = module.name + ".zip";
		Haxelib.submit(zipName);
	}
}