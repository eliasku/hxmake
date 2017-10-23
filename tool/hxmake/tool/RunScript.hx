package hxmake.tool;

import haxe.io.Path;
import hxmake.cli.CL;
import hxmake.cli.MakeLog;
import hxmake.core.Arguments;
import hxmake.core.MakeArgument;
import hxmake.utils.Haxe;
import hxmake.utils.Haxelib;
import hxmake.utils.HaxeTarget;
import hxmake.utils.Hxml;

class RunScript {

	static inline var INIT_MACRO_METHOD:String = "hxmake.macr.InitMacro.generateMainClass";

	public static function main() {
		var args = new Arguments(popRunCwd(Sys.args()));
		var logger = MakeLog.logger;

		logger.setupFilter(
			args.hasProperty(MakeArgument.SILENT),
			args.hasProperty(MakeArgument.VERBOSE)
		);

		if (!make(Sys.getCwd(), args)) {
			logger.error("Make compilation FAILED");
			Sys.exit(-1);
		}
	}

	static function popRunCwd(args:Array<String>):Array<String> {
		var result = args.copy();
		var env = Sys.getEnv("HAXELIB_RUN");
		if (env != null && env.length > 0 && Std.parseInt(env) != 0) {
			Sys.setCwd(result.pop());
		}
		return result;
	}

	// TODO: path exists (cwd, make, lib)
	static function make(path:String, arguments:Arguments):Bool {

		Sys.setCwd(path);

		var makePath = Path.join([path, "make"]);
		var libPath = Haxelib.classPath("hxmake", true);
		var isCompiler = arguments.hasProperty(MakeArgument.MAKE_COMPILER_MODE);

		var hxml = new Hxml();
		hxml.main = "HxMakeMain";
		hxml.libraries = [];
		hxml.classPath.push(libPath);
		hxml.defines.push("hxmake");
		if (arguments.hasProperty(MakeArgument.MAKE_COMPILER_LOG)) {
			hxml.defines.push("hxmake_compiler_log");
		}

		if (isCompiler) {
			hxml.target = HaxeTarget.Interp;
		}
		else {
			// TODO: try replace Neko by Node.js environment?
			hxml.target = HaxeTarget.Neko;
			hxml.output = "make.n";
		}

		hxml.macros.push('$INIT_MACRO_METHOD("$makePath",$isCompiler,[${toLiteralsArrayString(arguments.args)}])');

		hxml.showMacroTimes =
		hxml.showTimes = arguments.hasProperty(MakeArgument.MAKE_COMPILER_TIME);

		var result = Haxe.compile(hxml);
		if (!result || isCompiler) {
			return result;
		}

		return CL.command("neko", ["make.n"]) == 0;
	}

	static function toLiteralsArrayString(values:Array<String>):String {
		return values != null ? values.map(function(v:String) return '"$v"').join(",") : "";
	}
}
