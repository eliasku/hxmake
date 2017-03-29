package hxmake.tool;

import hxlog.Log;
import hxmake.cli.CL;
import hxmake.utils.HaxeTarget;
import hxmake.utils.Hxml;
import hxmake.utils.Haxe;
import hxmake.utils.Haxelib;
import haxe.io.Path;

@:final
class MakeRunner {

	static inline var INIT_MACRO_METHOD:String = "hxmake.macr.InitMacro.generateMainClass";

	// TODO path exists (cwd, make, lib)
	@:noUsing
	public static function make(path:String, builtInArguments:Array<String>):Bool {

		Sys.setCwd(path);

		var makePath = Path.join([path, "make"]);
		var libPath = Haxelib.classPath("hxmake", true);
		var isCompiler = builtInArguments.indexOf("--haxe") >= 0;

		var hxml = new Hxml();
		hxml.main = "HxMakeMain";
		hxml.libraries = ["hxlog"];
		hxml.classPath.push(libPath);
		hxml.defines.push("hxmake");

		if(isCompiler) {
			hxml.target = HaxeTarget.Interp;
		}
		else {
			hxml.target = HaxeTarget.Neko;
			hxml.output = "make.n";

			// TODO: switch to HL?
			// hxml.target = HaxeTarget.Hl;
			// hxml.defines.push("interp");
			// hxml.output = "make.hl";
		}

		hxml.macros.push('$INIT_MACRO_METHOD("$makePath",$isCompiler,[${toLiteralsArrayString(builtInArguments)}])');

		hxml.showMacroTimes =
		hxml.showTimes = builtInArguments.indexOf("--times") >= 0;

		var result = Haxe.compile(hxml);
		if(!result || isCompiler) {
			return result;
		}

		return CL.command("neko", ["make.n"]) == 0;
	}

	static function toLiteralsArrayString(values:Array<String>):String {
		var args = [];
		if(values != null) {
			for(v in values) {
				args.push('"$v"');
			}
		}
		return args.join(",");
	}
}
