package hxmake.tool;

import haxe.io.Path;
import hxmake.cli.CL;
import hxmake.cli.MakeLog;
import hxmake.utils.Haxe;
import hxmake.utils.Haxelib;
import sys.FileSystem;
import sys.io.File;

using StringTools;

@:final
class Installer {

	public static function run(library:String, ?alias:String):Bool {

		if (alias == null) {
			alias = library;
		}

		var libPath = Haxelib.libPath(library);
		if (libPath == null) {
			MakeLog.error('"$library" is not installed');
			return false;
		}

		if (!FileSystem.exists(libPath)) {
			MakeLog.error('"$library" not found at $libPath');
			return false;
		}

		MakeLog.trace('Use "$library" from "$libPath"');

		return CL.workingDir.with(libPath, function() {

			// COMPILATION
			if (!Haxe.exec(["build.hxml"])) {
				MakeLog.error("HxMake library build failed");
				return false;
			}

			if (CL.platform.isWindows && FileSystem.exists('$alias.exe')) {
				MakeLog.info('Alias should be installed already');
				MakeLog.info('If you need to reinstall alias script use:');
				MakeLog.info('> haxelib run $library _');
				return true;
			}

			if (CL.command('nekotools', ['boot', '$library.n']) != 0) {
				MakeLog.error('Failed to create alias-script executable');
				return false;
			}

			// INSTALL
			MakeLog.info('We`re going to install ${alias.toUpperCase()} command');
			MakeLog.info('Please enter password if required...');
			try {
				if (CL.platform.isWindows) {
					var haxePath = Haxe.path();
					var pn = '$alias.exe';
					var src = Path.join([libPath, pn]);
					var dst = Path.join([haxePath, pn]);
					MakeLog.trace('Copy hxmake.exe to $haxePath');
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
				MakeLog.error(e);
				MakeLog.error("Error while installing system command-line");
				return false;
			}

			return true;
		});
	}
}
