package hxmake.tool;

import hxmake.utils.HaxeTarget;
import hxmake.utils.Hxml;
import hxmake.utils.Haxe;
import hxmake.utils.Haxelib;
import haxe.io.Path;

@:final
class MakeRunner {

	// TODO path exists (cwd, make, lib)
	@:noUsing
	public static function make(path:String, args:Array<String>):Bool {

		Sys.setCwd(path);

		var makePath = Path.join([path, "make"]);
		var libPath = Haxelib.classPath("hxmake", true);

		var hxml = new Hxml();
		hxml.main = "HxMakeMain";
		hxml.classPath.push(libPath);
		hxml.defines.push("hxmake");
		hxml.macros.push('hxmake.macr.InitMacro.generateMainClass("${args.join(",")}","$makePath")');

		if(args.indexOf("--neko") >= 0) {
			hxml.target = HaxeTarget.Neko;
			hxml.output = "make.n";
			hxml.commands.push("neko make.n");
		}
		else {
			hxml.target = HaxeTarget.Interp;
		}

		hxml.showMacroTimes =
		hxml.showTimes = args.indexOf("--times") >= 0;

		return Haxe.compile(hxml);
	}
}
