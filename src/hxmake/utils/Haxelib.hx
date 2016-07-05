package hxmake.utils;

import haxe.io.Path;
import hxmake.cli.CL;

using StringTools;

class Haxelib {

	static inline var HAXE_PATH_ENV:String = "HAXEPATH";
	static inline var HAXE_PATH_WINDOWS:String = "C:\\HaxeToolkit\\haxe\\";
	static inline var HAXE_PATH_OSX:String = "/usr/local/lib/haxe/";
	static inline var HAXELIB_ALIAS:String = "haxelib";

	static var NEW_LINE_REGEX:EReg = ~/\r?\n/g;

	public static function getSourcePath(libraryName:String, global:Bool = false):String {
		var args = ["path", libraryName];
		if(global) {
			args.unshift("--global");
		}
		var result = CL.execute(HAXELIB_ALIAS, args);
		if(result.exitCode == 0) {
			var args = NEW_LINE_REGEX.split(result.stdout);
			for (arg in args) {
				if (arg.length > 0 && arg.charAt(0) != "-") {
					return arg;
				}
			}
		}
		return null;
	}

	public static function checkInstalled(libraryName:String):Bool {
		return getSourcePath(libraryName) != null;
	}

	public static function getHaxePath():String {
		var path = Sys.getEnv(HAXE_PATH_ENV);
		if (path == null || path == "") {
//			throw "Please set HAXEPATH environment variable";
			if (CL.platform.isWindows) {
				// useful trick from NME tool
				var nekoPath = Sys.programPath();
				var parts = nekoPath.split("\\");
				if (parts.length > 1 && parts[parts.length - 1] == "neko") {
					path = parts.slice(0, parts.length - 1).join("\\") + "\\haxe\\";
				}
				else {
					path = HAXE_PATH_WINDOWS;
				}
			}
			else {
				path = HAXE_PATH_OSX;
			}
		}
		return path;
	}

	// TODO: add class path support (make search from haxelib repo path)
	// TODO: support for version
	public static function getLibraryInstallPath(library:String, ?version:String, global:Bool = false):String {
		var libPath = Haxelib.getSourcePath(library, global);
		if(libPath == null) {
			return null;
		}
		// FIXME: temproary workaround
		if(Path.removeTrailingSlashes(libPath).endsWith("src")) {
			return Path.normalize(Path.join([libPath, ".."]));
		}
		return libPath;
	}
}
