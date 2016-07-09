package hxmake.tool;

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
			Sys.println('"$library" is not installed');
			return false;
		}

		Sys.println('Use "$library" from "$libPath"');
		// COMPILATION
		if(!CL.workingDir.with(libPath, Haxe.exec.bind(["build.hxml"]))) {
			Sys.println("HxMake library build failed");
			return false;
		}

		// INSTALL
		Sys.println('We`re going to install ${alias.toUpperCase()} command');
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
