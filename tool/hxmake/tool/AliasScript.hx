package hxmake.tool;

import haxe.io.Path;
import haxe.macro.Compiler;
import hxmake.cli.CL;
import hxmake.cli.LogConfig;
import hxmake.utils.Haxelib;

class AliasScript {
	public static function main() {
		LogConfig.initialize();
		var library = Compiler.getDefine("library");
		var toolPath = Haxelib.libPath(library, true);
		Sys.exit(CL.command("neko", [Path.join([toolPath, "run.n"])].concat(Sys.args())));
	}
}
