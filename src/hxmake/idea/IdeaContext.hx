package hxmake.idea;

import haxe.io.Path;
import haxe.Template;
import haxe.xml.Fast;
import hxmake.cli.CL;
import hxmake.cli.FileUtil;
import hxmake.cli.MakeLog;
import hxmake.idea.IdeaSdkData;
import hxmake.utils.Haxelib;
import sys.FileSystem;
import sys.io.File;

using hxmake.utils.ArrayTools;

@:final
class IdeaContext {

	public var appPath(default, null):String;
	public var configPath(default, null):String;

	public var sdkList:Array<IdeaSdkData> = [];

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

	public function getSdkName(type:IdeaSdkType, defaultName:String = "AIR_SDK"):String {
		var sdk:IdeaSdkData = getSdkListByType(type).back();
		return sdk != null ? sdk.name : defaultName;
	}

	public function getSdkListByType(type:IdeaSdkType):Array<IdeaSdkData> {
		return sdkList.filter(function(s:IdeaSdkData) {
			return s.type == type;
		});
	}

	public function openProject(path:String) {
		if (appPath == null) {
			MakeLog.warning("IDEA executable is not found");
			return;
		}
		if (CL.platform.isMac) {
			CL.execute("open", [path, "-a", Path.join([appPath, "Contents/MacOS/idea"])]);
		}
		else if (CL.platform.isWindows) {
			CL.execute("start", ["/b", Path.join([appPath, "bin/idea.exe"]), path]);
		}
		else if (CL.platform.isLinux) {
			// TODO:
		}
	}

	function resolveSdk() {
		if (configPath != null) {
			var jdkTableContent = File.getContent(getJdkTablePath(configPath));
			var jdkTableXml = Xml.parse(jdkTableContent);
			var fast = new Fast(jdkTableXml.firstElement());
			for (c in fast.nodes.component) {
				for (j in c.nodes.jdk) {
					var sdk:IdeaSdkData = IdeaSdkData.parseFromXml(j);
					if (sdk != null) {
						sdkList.push(sdk);
					}
				}
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
