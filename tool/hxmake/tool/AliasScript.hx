package hxmake.tool;

import haxe.io.Path;
import haxe.macro.Compiler;
import hxmake.cli.CL;
import hxmake.cli.MakeLog;
import hxmake.core.Arguments;
import hxmake.utils.Haxelib;

class AliasScript {
	public static function main() {
		var args = new Arguments(Sys.args());
		var logger = MakeLog.logger;
		logger.setupFilter(
			args.hasProperty("--silent"),
			args.hasProperty("--verbose")
		);
		var library = Compiler.getDefine("library");
		var toolPath = Haxelib.libPath(library, true);
		Sys.exit(CL.command("neko", [Path.join([toolPath, "run.n"])].concat(Sys.args())));
	}
}
