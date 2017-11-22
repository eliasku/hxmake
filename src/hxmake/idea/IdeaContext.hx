package hxmake.idea;

import haxe.io.Path;
import haxe.Template;
import haxe.xml.Fast;
import hxmake.cli.CL;
import hxmake.cli.FileUtil;
import hxmake.cli.MakeLog;
import hxmake.utils.Haxelib;
import sys.FileSystem;
import sys.io.File;

@:final
class IdeaContext {

	public var appPath(default, null):String;
	public var configPath(default, null):String;

	public var flexSdkList:Array<String> = [];
	public var haxeSdkList:Array<String> = [];

	public var iml(default, null):Template;
	public var xmlModules(default, null):Template;
	public var xmlMisc(default, null):Template;
	public var xmlHaxe(default, null):Template;
	public var xmlRunConfig(default, null):Template;

	public function new() {
		appPath = resolveApplicationPath();
		configPath = resolveConfigPath();
		resolveSdk();

		var hxmakePath = Haxelib.libPath("hxmake");
		iml = createTemplate(hxmakePath, "idea/module.iml.xml");
		xmlModules = createTemplate(hxmakePath, "idea/modules.xml");
		xmlHaxe = createTemplate(hxmakePath, "idea/haxe.xml");
		xmlRunConfig = createTemplate(hxmakePath, "idea/runConfiguration.xml");
		xmlMisc = createTemplate(hxmakePath, "idea/misc.xml");
	}

	public function getFlexSdkName() {
		return flexSdkList[flexSdkList.length - 1];
	}

	public function getHaxeSdkName() {
		return haxeSdkList[haxeSdkList.length - 1];
	}

	public function openProject(path:String) {
		if (appPath == null) {
			MakeLog.warning("IDEA executable is not found");
			return;
		}
		if (CL.platform.isMac) {
			CL.execute("open", ["-a", Path.join([appPath, "Contents/MacOS/idea"]), "--args", path]);
		}
		else if (CL.platform.isWindows) {
			CL.execute("start", ["/b", Path.join([appPath, "bin/idea.exe"]), path]);
		}
		else if (CL.platform.isLinux) {
			// TODO:
		}
	}

	/////

	function resolveSdk() {
		if (configPath != null) {
			var jdkTableContent = File.getContent(getJdkTablePath(configPath));
			var jdkTableXml = Xml.parse(jdkTableContent);
			var fast = new Fast(jdkTableXml.firstElement());
			for (c in fast.nodes.component) {
				for (j in c.nodes.jdk) {
					var type = j.node.type.att.value;
					var name = j.node.name.att.value;
					if (type.indexOf("Flex") == 0) {
						flexSdkList.push(name);
					}
					else if (type.indexOf("Haxe") == 0) {
						haxeSdkList.push(name);
					}
				}
			}

			if (flexSdkList.length == 0) {
				flexSdkList.push("AIR_SDK");
			}

			if (haxeSdkList.length == 0) {
				haxeSdkList.push("Haxe 3.4.0");
			}
		}
	}

	static function resolveConfigPath() {
		var pathes = findLatestPreferences();
		for (path in pathes) {
			MakeLog.trace("Found IntelliJ Idea config folder: " + path);
			return path;
		}
		MakeLog.error("IntelliJ Idea configuration is not found");
		return null;
	}

	static function findLatestPreferences():Array<String> {
		var result = [];
		var prefsPath = getUserPreferencesPath();
		var ideaPathName = CL.platform.isMac ? "IntelliJIdea" : ".IntelliJIdea";
		var versions = getVersions();

		MakeLog.trace('Search IntelliJ IDEA Preferences in: $prefsPath');

		versions.reverse();
		for (version in versions) {
			var path = Path.join([prefsPath, ideaPathName + version]);
			if (!CL.platform.isMac) {
				path = Path.join([path, "config"]);
			}
			if (vefiryPreferencesPath(path)) {
				result.push(path);
			}
		}
		return result;
	}

	static function vefiryPreferencesPath(path:String):Bool {
		return FileUtil.dirExists(path) && FileUtil.fileExists(getJdkTablePath(path));
	}

	static function getJdkTablePath(path:String):String {
		return Path.join([path, "options", "jdk.table.xml"]);
	}

	static function getUserPreferencesPath():String {
		var userHome = CL.getUserHome();
		return CL.platform.isMac ? Path.join([userHome, "Library", "Preferences"]) : userHome;
	}

	static function getVersions():Array<String> {
		var result = [];
		for (major in 16...20) {
			result.push('20$major');
			for (minor in 1...10) {
				result.push('20$major.$minor');
			}
		}
		return result;
	}

	static function resolveApplicationPath():Null<String> {
		var candidates = [];

		if (CL.platform.isMac) {
			var applicationsDirs = ["/Applications", Path.join([CL.getUserHome(), "Applications"])];
			for (applicationsDir in applicationsDirs) {
				if (FileUtil.dirExists(applicationsDir)) {
					var list = FileSystem.readDirectory(applicationsDir);
					for (appDir in list) {
						if (appDir.indexOf("IntelliJ IDEA") >= 0) {
							candidates.push(Path.join([applicationsDir, appDir]));
						}
					}
				}
			}
		}
		else if (CL.platform.isWindows) {
			var variances = [
				"\\Program Files (x86)\\JetBrains",
				"\\Program Files\\JetBrains",
				"\\Program Files (x86)",
				"\\Program Files"
			];
			var applicationsDirs = variances.map(function(v:String) {
				return Sys.getEnv("SYSTEMDRIVE") + v;
			});
			applicationsDirs = applicationsDirs.concat(variances.map(function(v:String) {
				return Sys.getEnv("HOMEDRIVE") + v;
			}));
			for (applicationsDir in applicationsDirs) {
				if (FileUtil.dirExists(applicationsDir)) {
					var list = FileSystem.readDirectory(applicationsDir);
					for (appDir in list) {
						if (appDir.indexOf("IntelliJ IDEA") >= 0) {
							candidates.push(Path.join([applicationsDir, appDir]));
						}
					}
				}
			}
		}

		if (candidates.length > 0) {
			candidates.sort(function(a:String, b:String) {
				return -Reflect.compare(a, b);
			});
			return candidates[0];
		}

		return null;
	}

	static function createTemplate(hxmakePath:String, resource:String) {
		return new Template(File.getContent(Path.join([hxmakePath, "resources", resource])));
	}
}
