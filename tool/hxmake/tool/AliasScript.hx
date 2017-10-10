package hxmake.tool;

import haxe.io.Path;
import haxe.macro.Compiler;
import hxmake.cli.CL;
import hxmake.cli.MakeLog;
import hxmake.utils.Haxelib;

class AliasScript {
	public static function main() {
		var args = Sys.args();
		MakeLog.initialize(args.indexOf("--silent") >= 0, args.indexOf("--verbose") >= 0);
		var library = Compiler.getDefine("library");
		var toolPath = Haxelib.libPath(library, true);
		Sys.exit(CL.command("neko", [Path.join([toolPath, "run.n"])].concat(Sys.args())));
	}
}
