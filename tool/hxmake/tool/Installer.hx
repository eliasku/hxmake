package hxmake.tool;

import hxlog.Log;
import sys.FileSystem;
import hxmake.cli.ProcessResult;
import hxmake.utils.Haxe;
import hxmake.utils.Haxelib;
import haxe.io.Path;
import sys.io.File;
import hxmake.cli.CL;

using StringTools;

@:final
class Installer {

	public static function run(library:String, ?alias:String):Bool {

		if(alias == null) {
			alias = library;
		}

		var haxePath = Haxe.path();
		var libPath = Haxelib.libPath(library);
		if(libPath == null || !FileSystem.exists(libPath)) {
			Log.info('"$library" is not installed');
			return false;
		}

		Log.info('Use "$library" from "$libPath"');

		return CL.workingDir.with(libPath, function() {

			// COMPILATION
			if(!Haxe.exec(["build.hxml"])) {
				Log.info("HxMake library build failed");
				return false;
			}

			if(CL.platform.isWindows && FileSystem.exists('$alias.exe')) {
				Log.info('Alias should be installed already');
				Log.info('If you need to reinstall alias script use:');
				Log.info('> haxelib run $library _');
				return true;
			}

			if(Sys.command('nekotools', ['boot', '$library.n']) != 0) {
				Log.error('Failed to create alias-script executable');
				return false;
			}

			// INSTALL
			Log.info('We`re going to install ${alias.toUpperCase()} command');
			Log.info('Please enter password if required...');
			try {
				if (CL.platform.isWindows) {
					var pn = '$alias.exe';
					var src = Path.join([libPath, pn]);
					var dst = Path.join([haxePath, pn]);
					Log.info('Copy hxmake.exe to $haxePath');
					File.copy(src, dst);

					// TODO:
					// we need delete hxmake.exe to prevent running from the current folder:
					// - if hxmake.exe will be runned from current folder, OS will not able to overwrite the file
					// FileSystem.deleteFile(src);
				}
				else {
					var pn = '$alias';
					var rp = "/usr/local/bin/" + pn;
					Sys.command("sudo", ["cp", "-f", Path.join([libPath, pn]), rp]);
					Sys.command("sudo", ["chmod", "755", rp]);
				}
			}
			catch (e:Dynamic) {
				Log.error(e);
				Log.error("Error while installing system command-line");
				return false;
			}

			return true;
		});
	}
}
