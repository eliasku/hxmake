package hxmake.tool;

import haxe.Timer;
import hxmake.cli.MakeLog;
import hxmake.core.Arguments;

class RunScript {

	public static function main() {
		var args = new Arguments(popRunCwd(Sys.args()));
		var logger = MakeLog.logger;

		logger.setupFilter(
			args.hasProperty("--silent"),
			args.hasProperty("--verbose")
		);

		var success = measure(
			function() { return args.hasTask("_") ? Installer.run("hxmake") : MakeRunner.make(Sys.getCwd(), args.args); },
			args.hasProperty("--times") ? function(totalTime:Float) { logger.info('Total time: $totalTime sec.'); } : null
		);

		if (!success) {
			logger.error("hxmake FAILED");
			Sys.exit(-1);
		}
	}

	static function measure<T>(func:Void -> T, callback:Float -> Void):T {
		if (callback == null) {
			return func();
		}

		var startTime = Timer.stamp();
		var result = func();
		callback(Std.int(100 * (Timer.stamp() - startTime)) / 100);
		return result;
	}

	static function popRunCwd(args:Array<String>):Array<String> {
		var result = args.copy();
		var env = Sys.getEnv("HAXELIB_RUN");
		if (env != null && env.length > 0 && Std.parseInt(env) != 0) {
			Sys.setCwd(result.pop());
		}
		return result;
	}
}
