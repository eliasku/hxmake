package hxmake.cli;

import sys.FileSystem;
import sys.io.Process;

class CL {

	public static var workingDir(default, null):WorkingDirectory = new WorkingDirectory();
	public static var platform(default, null):Platform = resolvePlatform();

	public static function execute(command:String, args:Array<String>, ?workingDirectory:String):ProcessResult {
		Debug.log("EXECUTE: " + command + " " + args.join(" "));
		if (workingDirectory != null) {
			CL.workingDir.push(workingDirectory);
		}

		var process = new Process(command, args);
		var result = new ProcessResult();
		result.exitCode = process.exitCode();
		result.stdout = process.stdout.readAll().toString();
		result.stderr = process.stderr.readAll().toString();
		process.close();

		if (workingDirectory != null) {
			CL.workingDir.pop();
		}

		return result;
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
