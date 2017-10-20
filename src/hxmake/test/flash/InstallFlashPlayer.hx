package hxmake.test.flash;

import haxe.Http;
import haxe.io.Path;
import hxmake.cli.CL;
import hxmake.cli.Platform;
import sys.FileSystem;
import sys.io.File;

class InstallFlashPlayer extends SetupTask {

	var _fpUrl:String;
	var _fpTrust:String;
	var _mmCfg:String;

	public function new() {
		super();
	}

	function checkInstalled():Bool {
		return switch(CL.platform) {
			case Platform.LINUX: FileSystem.exists(Sys.getEnv("HOME") + "/flashplayerdebugger");
			case Platform.MAC: FileSystem.exists("/Applications/Flash Player Debugger.app");
			case Platform.WINDOWS: FileSystem.exists("flash/flashplayer.exe");
			case _: throw "unknown platform";
		}
	}

	override public function run() {
		super.run();

		if (!checkInstalled()) {
			project.logger.info("FLASH PLAYER NOT FOUND");
			switch (CL.platform) {
				case Platform.LINUX:
					CL.command("sudo", ["dpkg", "--add-architecture", "i386"]);
					CL.command("sudo", ["apt-get", "update", "-qq"]);
					for (p in [
						"libgtk2.0-0:i386", "libxt6:i386", "libnss3:i386", "libcurl3:i386",
						"xvfb"
					]) {
						if (!CiTools.isPackageInstalled(p)) {
							// do not fail on Error;
							CL.command("sudo", ["apt-get", "install", "-y", p]);
						}
					}
					// Download and unzip flash player
					if (CL.command("wget", ["-nv", _fpUrl]) != 0) {
						throw "failed to download flash player";
					}
					if (CL.command("tar", ["-xf", FileSystem.absolutePath(Path.withoutDirectory(_fpUrl)), "-C", Sys.getEnv("HOME")]) != 0) {
						throw "failed to extract flash player";
					}
				case Platform.MAC:
					if (CL.command("brew", ["cask", "install", "flash-player-debugger", "--force"]) != 0) {
						// uninstall cask
						CL.command("brew", ["uninstall", "--force", "brew-cask"]);
						CL.command("brew", ["untap", "phinze/cask"]);
						CL.command("brew", ["untap", "caskroom/cask"]);
						// update brew and cask
						CL.command("brew", ["update"]);
						CL.command("brew", ["cleanup"]);
						CL.command("brew", ["cask", "cleanup"]);
//                        if (Sys.command("brew", ["tap", "caskroom/cask"]) != 0) {
//                            MakeLog.error("Failed to install brew cask, maybe already installed");
//                        }
						if (CL.command("brew", ["cask", "install", "flash-player-debugger", "--force"]) != 0) {
							fail("Failed to install flash-player-debugger");
						}
					}
				case Platform.WINDOWS:
					var fpPath = "flash";
					if (!FileSystem.exists(fpPath)) {
						FileSystem.createDirectory(fpPath);
					}
					// Download flash player
					download(_fpUrl, '$fpPath\\flashplayer.exe');
				case _:
					throw "unsupported system";
			}
		}

		File.saveContent(_mmCfg, "ErrorReportingEnable=1\nTraceOutputFileEnable=1");

		try {
			// Add the current directory as trusted, so exit() can be used
			if (!FileSystem.exists(_fpTrust)) {
				FileSystem.createDirectory(_fpTrust);
			}
			File.saveContent(Path.join([_fpTrust, "test.cfg"]), Sys.getCwd());
		}
		catch (e:Dynamic) {
			// TODO: message
			project.logger.warning('Cannot add current directory to trusted locations');
		}
	}

	override public function configure() {
		_fpUrl = getFpDownload();
		_fpTrust = getFpTrust();
		_mmCfg = getMmCfg();
	}

	static function getFpDownload():String {
		// https://www.adobe.com/support/flashplayer/downloads.html
		return switch(CL.platform) {
			case Platform.LINUX:
				"http://fpdownload.macromedia.com/pub/flashplayer/updaters/11/flashplayer_11_sa_debug.i386.tar.gz";
			case Platform.MAC:
				"http://fpdownload.macromedia.com/pub/flashplayer/updaters/21/flashplayer_21_sa_debug.dmg";
			case Platform.WINDOWS:
				"http://fpdownload.macromedia.com/pub/flashplayer/updaters/21/flashplayer_21_sa_debug.exe";
			case _:
				throw "unsupported system";
		}
	}

	static function getMmCfg():String {
		// https://helpx.adobe.com/flash-player/kb/configure-debugger-version-flash-player.html
		return switch(CL.platform) {
			case Platform.LINUX, Platform.MAC:
				Path.join([Sys.getEnv("HOME"), "mm.cfg"]);
			case Platform.WINDOWS:
				Path.join([Sys.getEnv("HOMEDRIVE") + Sys.getEnv("HOMEPATH"), "mm.cfg"]);
			case _:
				throw "unsupported system";
		}
	}


	static function getFpTrust():String {
		// http://help.adobe.com/en_US/ActionScript/3.0_ProgrammingAS3/WS5b3ccc516d4fbf351e63e3d118a9b90204-7c91.html#WSD2DCB535-92C6-49ff-8954-D8D5130404F1
		return Path.join(
			switch (CL.platform) {
				case Platform.LINUX:
					[Sys.getEnv("HOME"), ".macromedia/Flash_Player/#Security/FlashPlayerTrust"];
				case Platform.MAC:
					[Sys.getEnv("HOME"), "Library", "Preferences", "Macromedia", "Flash Player", "#Security", "FlashPlayerTrust"];
				case Platform.WINDOWS:
					[Sys.getEnv("APPDATA"), "Macromedia", "Flash Player", "#Security", "FlashPlayerTrust"];
				case _:
					throw "unsupported system";
			}
		);
	}

	function download(url:String, saveAs:String) {
		project.logger.info('Downloading $url to $saveAs...');
		var http = new Http(url);
		http.onError = function(e) {
			throw e;
		};
		http.customRequest(false, File.write(saveAs));
	}
}
