package hxmake.tool;

import hxmake.utils.Haxelib;
import haxe.io.Path;

@:final
class MakeRunner {

	public static function make(path:String, args:Array<String>) {
		var projectClassPath = Path.join([path, "make"]);
		Sys.setCwd(path);

		var hxmakePath = Haxelib.getSourcePath("hxmake", true);

		var hxml = [
			"-cp", hxmakePath,
			"-D", "hxmake",
			"--macro", "hxmake.macr.InitMacro.generateMainClass('" + args.join(",") + "','" + projectClassPath + "')",
			"-main", "HxMakeMain"
		];

		if(args.indexOf("--neko") >= 0) {
			hxml = hxml.concat([
				"-neko", "make.n",
				"-cmd", "neko make.n"
			]);
		}
		else {
			hxml.push("--interp");
		}

		if(args.indexOf("--times") >= 0) {
			hxml = hxml.concat([
				"--times",
				"-D", "macro-times"
			]);
		}

		Sys.println("Result code: " + Sys.command("haxe", hxml));
	}
}
