package hxmake.tool;

import hxmake.cli.MakeLog;
import haxe.Timer;

class RunScript {

	public static function main() {
		var args = popRunCwd(Sys.args());
		var success = false;

		MakeLog.initialize(args);

		measure(function() {
			success = run(args);
		}, args.indexOf("--times") < 0);

		if(!success) {
			MakeLog.error("hxmake FAILED");
			Sys.exit(-1);
		}
	}

	static function run(args:Array<String>):Bool {
		if(args.indexOf("_") >= 0) {
			return Installer.run("hxmake");
		}
		return MakeRunner.make(Sys.getCwd(), args);
	}

	static function measure(func:Void->Void, bypass:Bool = false) {
		if(bypass) {
			func();
			return;
		}

		var startTime = Timer.stamp();
		func();
		var totalTime = Std.int(100 * (Timer.stamp() - startTime)) / 100;
		MakeLog.info("Total time: " + totalTime + " sec.");
	}

	static function popRunCwd(args:Array<String>):Array<String> {
		var result = args.copy();
		var env = Sys.getEnv("HAXELIB_RUN");
		if(env != null && env.length > 0 && Std.parseInt(env) != 0) {
			Sys.setCwd(result.pop());
		}
		return result;
	}
}
