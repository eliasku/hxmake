package hxmake.tasks;

import haxe.io.Path;
import hxmake.cli.CL;
import hxmake.cli.logging.Logger;
import hxmake.utils.Haxe;
import hxmake.utils.Haxelib;
import sys.FileSystem;
import sys.io.File;

@:final
class InstallTask extends Task {

	public function new() {
		name = "_";
		description = "Rebuild and install `hxmake` binary";
	}

	override public function run() {
		if (!install(project.logger, "hxmake")) {
			project.logger.error("hxmake installation FAILED");
			throw "stop execution";
		}
	}

	static function install(logger:Logger, library:String, ?alias:String):Bool {
		if (alias == null) {
			alias = library;
		}

		var libPath = Haxelib.libPath(library);
		if (libPath == null) {
			logger.error('"$library" is not installed');
			return false;
		}

		if (!FileSystem.exists(libPath)) {
			logger.error('"$library" not found at $libPath');
			return false;
		}

		logger.trace('Use "$library" from "$libPath"');

		return CL.workingDir.with(libPath, function() {

			// COMPILATION
			if (!Haxe.exec(["build.hxml"])) {
				logger.error("HxMake library build failed");
				return false;
			}

			if (CL.platform.isWindows && FileSystem.exists('$alias.exe')) {
				logger.info('Alias should be installed already');
				logger.info('If you need to reinstall alias script use:');
				logger.info('> haxelib run $library _');
				return true;
			}

			if (CL.command('nekotools', ['boot', '$library.n']) != 0) {
				logger.error('Failed to create alias-script executable');
				return false;
			}

			// INSTALL
			logger.info('We`re going to install ${alias.toUpperCase()} command');
			logger.warning('Please enter password if required...');
			try {
				if (CL.platform.isWindows) {
					var haxePath = Haxe.path();
					var pn = '$alias.exe';
					var src = Path.join([libPath, pn]);
					var dst = Path.join([haxePath, pn]);
					logger.trace('Copy hxmake.exe to $haxePath');
					File.copy(src, dst);

					// TODO: windows replace .exe issue
					// we need delete hxmake.exe to prevent running from the current folder:
					// - if hxmake.exe will be runned from current folder, OS will not able to overwrite the file
					// FileSystem.deleteFile(src);
				}
				else {
					var pn = '$alias';
					var rp = "/usr/local/bin/" + pn;
					CL.command("sudo", ["cp", "-f", Path.join([libPath, pn]), rp]);
					CL.command("sudo", ["chmod", "755", rp]);
				}
			}
			catch (e:Dynamic) {
				logger.error(e);
				logger.error("Error while installing system command-line");
				return false;
			}

			return true;
		});
	}
}
