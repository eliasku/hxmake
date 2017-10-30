package hxmake.tool;

import haxe.io.Path;
import hxmake.cli.CL;
import hxmake.cli.MakeLog;
import hxmake.core.Arguments;
import hxmake.core.MakeArgument;
import hxmake.utils.Haxelib;

class AliasScript {
	public static function main() {
		var args = new Arguments(Sys.args());
		MakeLog.logger.setupFilter(
			args.hasProperty(MakeArgument.SILENT),
			args.hasProperty(MakeArgument.VERBOSE)
		);
		var toolPath = Haxelib.libPath("hxmake", true);
		Sys.exit(CL.command("neko", [Path.join([toolPath, "run.n"])].concat(Sys.args())));
	}
}
