package hxmake.tool;

import haxe.io.Path;
import hxmake.utils.Haxelib;
import haxe.macro.Compiler;

class AliasScript {
	public static function main() {
		//var alias = Compiler.getDefine("alias");
		var library = Compiler.getDefine("library");
		var toolPath = Haxelib.getLibraryInstallPath(library, null, true);
		//Sys.exit(Sys.command("haxelib", ["--global", "run", alias].concat(Sys.args())));
		Sys.exit(Sys.command("neko", [Path.join([toolPath, "run.n"])].concat(Sys.args())));
	}
}
