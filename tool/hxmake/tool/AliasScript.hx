package hxmake.tool;

import hxmake.utils.Haxelib;
import haxe.io.Path;
import haxe.macro.Compiler;

class AliasScript {
	public static function main() {
		//var alias = Compiler.getDefine("alias");
		var library = Compiler.getDefine("library");
		var toolPath = Haxelib.libPath(library, true);
		//Sys.exit(Sys.command("haxelib", ["--global", "run", alias].concat(Sys.args())));
		Sys.exit(Sys.command("neko", [Path.join([toolPath, "run.n"])].concat(Sys.args())));
	}
}
