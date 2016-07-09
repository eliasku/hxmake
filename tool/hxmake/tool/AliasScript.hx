package hxmake.tool;

import hxmake.utils.Haxelib;
import haxe.io.Path;
import haxe.macro.Compiler;

class AliasScript {
	public static function main() {
		var library = Compiler.getDefine("library");
		var toolPath = Haxelib.libPath(library, true);
		Sys.exit(Sys.command("neko", [Path.join([toolPath, "run.n"])].concat(Sys.args())));
	}
}
