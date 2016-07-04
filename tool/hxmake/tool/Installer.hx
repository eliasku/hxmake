package hxmake.tool;

import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import hxmake.cli.Platform;
import hxmake.cli.CL;
import hxmake.utils.Haxelib;

using StringTools;

@:final
class Installer {

	public static function run(library:String, ?alias:String):Bool {

		if(alias == null) {
			alias = library;
		}

		var haxePath = Haxelib.getHaxePath();
		var libPath = Haxelib.getLibraryInstallPath(library);
		if(libPath == null) {
			Sys.println('\'$library\' is not installed');
			return false;
		}

		Sys.println('\'$library\' library path: $libPath');

		// COMPILATION
		var result = CL.execute("haxe", [Path.join([libPath, "build.hxml"])], libPath);
		if (result.exitCode != 0) {
			Sys.println("Build failed:\n\n" + result.stderr);
			return false;
		}

		// INSTALL
		Sys.println('We are going to install ${alias.toUpperCase()} command');
		Sys.println('Please enter password if required...');
		try {
			if (CL.platform.isWindows) {
				var pn = '$alias.exe';
				File.copy(Path.join([libPath, pn]), Path.join([haxePath, pn]));
			}
			else {
				var pn = '$alias';
				var rp = "/usr/local/bin/" + pn;
				Sys.command("sudo", ["cp", "-f", Path.join([libPath, pn]), rp]);
				Sys.command("sudo", ["chmod", "755", rp]);
			}
		}
		catch (e:Dynamic) {
			Sys.println(e);
			Sys.println("Error while installing system command-line");
			return false;
		}

		return true;
	}
}
