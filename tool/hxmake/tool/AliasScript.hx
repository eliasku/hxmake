package hxmake.tool;

import hxmake.cli.MakeLog;
import haxe.io.Path;
import haxe.macro.Compiler;
import hxmake.cli.CL;
import hxmake.utils.Haxelib;

class AliasScript {
	public static function main() {
		MakeLog.initialize(Sys.args());
		var library = Compiler.getDefine("library");
		var toolPath = Haxelib.libPath(library, true);
		Sys.exit(CL.command("neko", [Path.join([toolPath, "run.n"])].concat(Sys.args())));
	}
}
