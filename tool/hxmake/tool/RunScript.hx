package hxmake.tool;

import haxe.Timer;
import hxmake.cli.CL;

class RunScript {

	public static function main() {
		var args:Array<String> = Sys.args();
		popRunCwd(args);

		var startTime:Float = Timer.stamp();

		if(args.indexOf("_") >= 0) {
			Installer.run("hxmake");
		}
		else {
			//MakeRunner.make(CL.workingDir.current, args);
			MakeRunner.make(Sys.getCwd(), args);
		}

		var totalTime = Std.int(100 * (Timer.stamp() - startTime)) / 100;
		if(args.indexOf("--times") >= 0) {
			Sys.println("Total time: " + totalTime + " sec.");
		}
	}

	static function popRunCwd(args:Array<String>) {
		// TODO: check on WINDOWS / MAC
		var env = Sys.getEnv("HAXELIB_RUN");
		if(env != null && env.length > 0 && Std.parseInt(env) != 0) {
			//CL.workingDir.push(args.pop());
			Sys.setCwd(args.pop());
		}
	}
}
