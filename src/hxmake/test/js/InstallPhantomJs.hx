package hxmake.test.js;

import hxmake.cli.CL;

class InstallPhantomJs extends Task {

	public function new() {}

	override public function run() {
		if (CL.command("phantomjs", ["-v"]) != 0) {
			CiTools.installPackage("phantomjs");
		}
	}
}
