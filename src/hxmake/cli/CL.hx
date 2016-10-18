package hxmake.cli;

import sys.io.Process;
import hxlog.Log;
import sys.FileSystem;

class CL {

	public static var workingDir(default, null):WorkingDirectory = new WorkingDirectory();
	public static var platform(default, null):Platform = resolvePlatform();

	public static function execute(cmd:String, args:Array<String>):ProcessResult {
		var argsline = args != null ? args.join(" ") : "";
		Log.trace('<proc> $cmd $argsline');

		var result = new ProcessResult();

		try {
			var process = new Process(cmd, args);
			result.stdout = process.stdout.readAll().toString();
			result.stderr = process.stderr.readAll().toString();
			result.exitCode = process.exitCode();
			process.close();
		}
		catch(e:Dynamic) {
			result.exitCode = 0xFFFF;
		}

//		Log.trace(result.stdout);
//		Log.trace(result.stderr);
//		Log.trace(result.exitCode);

		return result;
	}

	public static function command(cmd:String, ?args:Array<String>):Int {
		var argline = args != null ? args.join(" ") : "";
		Log.trace('> $cmd $argline');
		var exitCode = Sys.command(cmd, args);
		if (exitCode != 0) {
			Log.trace('> $cmd exited: $exitCode');
		}
		return exitCode;
	}

	static function resolvePlatform():Platform {
		var result:Platform = Platform.UNKNOWN;
		var systemName = Sys.systemName();

		if (~/window/i.match(systemName)) {
			result = Platform.WINDOWS;
		}
		else if (~/linux/i.match(systemName)) {
			result = Platform.LINUX;
		}
		else if (~/mac/i.match(systemName)) {
			result = Platform.MAC;
		}

		return result;
	}

	public static function getUserHome():String {
		var homeDir:String = switch(platform) {
			case Platform.WINDOWS:
				Sys.getEnv("HOMEDRIVE") + Sys.getEnv("HOMEPATH");
			case _:
				Sys.getEnv("HOME");
		}
		if (homeDir != null && homeDir.length > 0 && FileSystem.exists(homeDir) && FileSystem.isDirectory(homeDir)) {
			return homeDir;
		}
		throw "HOME FOLDER is not found!";
	}
}
