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

		if(CL.platform.isWindows && FileSystem.exists('$alias.exe')) {
			if(Path.withoutDirectory(Sys.executablePath()) == "$alias.exe") {
				Sys.println("Alias should be installed already");
				Sys.println("If you need to reinstall alias script use:");
				Sys.println("> haxelib run $library _");
				return true;
			}
		}

		if(Sys.command("nekotools", ["boot", "$library.n"]) != 0) {
			Sys.println("Failed to create alias-script executable");
			return false;
		}

		// INSTALL
		Sys.println('We`re going to install ${alias.toUpperCase()} command');
		Sys.println('Please enter password if required...');
		try {
			if (CL.platform.isWindows) {
				var pn = '$alias.exe';
				var src = Path.join([libPath, pn]);
				var dst = Path.join([haxePath, pn]);
				Sys.println('Copy hxmake.exe to $haxePath');
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
			Sys.println(e);
			Sys.println("Error while installing system command-line");
			return false;
		}

		return true;
	}
}
