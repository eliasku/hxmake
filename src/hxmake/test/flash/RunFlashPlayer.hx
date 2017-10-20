package hxmake.test.flash;

import haxe.io.Path;
import hxmake.cli.CL;
import hxmake.cli.Platform;
import sys.FileSystem;
import sys.io.File;

class RunFlashPlayer extends RunTask {

	public var swfPath:Null<String>;

	public function new(?swfPath:String) {
		super();
		this.swfPath = swfPath;
	}

	override public function configure() {
		if (swfPath == null) {
			fail('Specify "swfPath" for RunFlashPlayer task');
		}

		switch (CL.platform) {
			case Platform.LINUX:
				set("xvfb-run", ["-a", FileSystem.absolutePath(Sys.getEnv("HOME") + "/flashplayerdebugger"), FileSystem.absolutePath(swfPath)]);
				retryUntilZero = 8;
			case Platform.MAC:
				set("/Applications/Flash Player Debugger.app/Contents/MacOS/Flash Player Debugger", [FileSystem.absolutePath(swfPath)]);
			case Platform.WINDOWS:
				set("flash\\flashplayer.exe", [FileSystem.absolutePath(swfPath)]);
			case _:
				throw "unsupported platform";
		}
	}

	override function execute() {
		super.execute();
		project.logger.info(File.getContent(getFlashLog()));
	}

	// https://helpx.adobe.com/flash-player/kb/configure-debugger-version-flash-player.html
	static function getFlashLog() {
		return Path.join(
			switch (CL.platform) {
				case Platform.LINUX:
					[Sys.getEnv("HOME"), ".macromedia/Flash_Player/Logs/flashlog.txt"];
				case Platform.MAC:
					[Sys.getEnv("HOME"), "Library/Preferences/Macromedia/Flash Player/Logs/flashlog.txt"];
				case Platform.WINDOWS:
					[Sys.getEnv("APPDATA"), "Macromedia", "Flash Player", "Logs", "flashlog.txt"];
				case _:
					throw "unsupported system";
			}
		);
	}
}
