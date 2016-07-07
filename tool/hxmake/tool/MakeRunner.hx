package hxmake.tool;

import hxmake.utils.HaxeTarget;
import hxmake.utils.Hxml;
import hxmake.utils.Haxe;
import hxmake.utils.Haxelib;
import haxe.io.Path;

@:final
class MakeRunner {

	public static function make(path:String, args:Array<String>):Bool {
		// TODO path exists
		// TODO make-path exists
		Sys.setCwd(path);
		var makePath = Path.join([path, "make"]);
		var libPath = Haxelib.classPath("hxmake", true);
		var hxml2 = new Hxml();
		hxml2.main = "HxMakeMain";
		hxml2.classPath.push(libPath);
		hxml2.defines.push("hxmake");
		hxml2.macros.push('hxmake.macr.InitMacro.generateMainClass("${args.join(",")}","$makePath")');
//		var hxml = [
//			"-cp", classPath,
//			"-D", "hxmake",
//			"--macro", "hxmake.macr.InitMacro.generateMainClass('" + args.join(",") + "','" + classPath + "')",
//			"-main", "HxMakeMain"
//		];

		if(args.indexOf("--neko") >= 0) {
			hxml2.target = HaxeTarget.Neko;
			hxml2.output = "make.n";
			hxml2.commands.push("neko make.n");
//			hxml = hxml.concat([
//				"-neko", "make.n",
//				"-cmd", "neko make.n"
//			]);
		}
		else {
			hxml2.target = HaxeTarget.Interp;
			//hxml.push("--interp");
		}

		hxml2.showMacroTimes =
		hxml2.showTimes = args.indexOf("--times") >= 0;
//		if(args.indexOf("--times") >= 0) {
//			hxml = hxml.concat([
//				"--times",
//				"-D", "macro-times"
//			]);
//		}

//		return Haxe.exec(hxml);
		return Haxe.compile(hxml2);
	}
}
