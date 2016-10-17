package hxmake.idea;

import hxlog.Log;
import hxmake.idea.IdeaProjectTask.IdeaLibraryInfo;
import hxmake.utils.Haxelib;
import sys.FileSystem;
import hxmake.macr.CompileTime;
import hxmake.cli.CL;
import hxmake.cli.FileUtil;
import sys.io.File;
import haxe.io.Path;
import haxe.Template;

using StringTools;

class IdeaLibraryInfo {
	public var name:String;
	public var classPath:Array<String>;

	public function new(name:String, classPath:Array<String>) {
		this.name = name;
		this.classPath = classPath;
	}
}

class IdeaProjectTask extends Task {

	var _iml:Template;
	var _xmlModules:Template;
	var _xmlHaxe:Template;
	var _xmlRunConfig:Template;
	var _ideaConfig:IdeaUserConfig;

	var _modules:Array<Module>;
	var _rootModule:Module;
	var _depCache:Map<String, IdeaLibraryInfo> = new Map();

	public function new() {}

	override public function run() {
		_iml = new Template(CompileTime.readFile("../resources/idea/module.iml.xml"));
		_xmlModules = new Template(CompileTime.readFile("../resources/idea/modules.xml"));
		_xmlHaxe = new Template(CompileTime.readFile("../resources/idea/haxe.xml"));
		_xmlRunConfig = new Template(CompileTime.readFile("../resources/idea/runConfiguration.xml"));
		_ideaConfig = new IdeaUserConfig();

		_modules = module.allModules;
		_rootModule = module;
		for (mod in _modules) {
			createModule(mod);
		}
		createProject(_rootModule.path);
		createRun(_rootModule.path);
		openIdeaProject(_rootModule.path);
	}

	function createModule(module:Module) {
		var modules = getModules(module);
		var libraries = getExternalLibraries(module);

		var testPath = module.config.testPath.concat(module.config.makePath);
		if(FileSystem.exists(Path.join([module.path, "makeplugin"]))) {
			testPath.push("makeplugin");
		}

		var context = {
			moduleName: module.name,
			moduleDependencies: modules,
			moduleLibraries: libraries,
			sourceDirs: module.config.classPath,
			testDirs: testPath,
			flexSdkName: _ideaConfig.getFlexSdkName(),
			haxeSdkName: _ideaConfig.getHaxeSdkName(),
			buildConfig: 1,
			projectPath: "",
			projectTarget: "",
			skipCompilation: true
		};

		var ideaData:IdeaData = module.get("idea", IdeaData);
		if (ideaData != null) {
			if (ideaData.hxml != null) {
				var buildHxml = ideaData.hxml;
				var p = Path.join(["$MODULE_DIR$", buildHxml]);
				var t = "Flash";
				context.buildConfig = 1;
				context.skipCompilation = false;
				context.projectPath = '<option name="hxmlPath" value="$p" />';
				context.projectTarget = '<option name="haxeTarget" value="$t" />';
			}
			else if (ideaData.lime != null) {
				var limeProjectPath = ideaData.lime;
				var p = Path.join(["$MODULE_DIR$", limeProjectPath]);
				var t = "Flash";
				context.buildConfig = 3;
				context.projectPath = '<option name="openFLPath" value="$p" />';
				context.projectTarget = '<option name="openFLTarget" value="$t" />';
			}
		}

		var iml = _iml.execute(context);
		Log.info("Writing " + module.name + ".iml");
		FileUtil.deleteFiles(module.path, "*.iml");
		File.saveContent(Path.join([module.path, '${module.name}.iml']), iml);
	}

	function createProject(path:String) {
		Log.info("SETUP IDEA PROJECT...");

		var context = {
			modules: []
		};

		for (module in _modules) {
			var ideaData:IdeaData = module.get("idea", IdeaData);
			var modulePath:String = module.path.replace(path, "");
			var moduleData = {
				path: '$modulePath/${module.name}.iml',
				groupAddon: ""
			};
			context.modules.push(moduleData);

			if (ideaData != null && ideaData.group != null) {
				moduleData.groupAddon = ' group="${ideaData.group}" ';
			}
		}

		var dotIdeaPath = Path.join([path, ".idea"]);
		if (!FileSystem.exists(dotIdeaPath)) {
			FileSystem.createDirectory(dotIdeaPath);
		}

		var haxeXmlPath = Path.join([dotIdeaPath, "haxe.xml"]);
		if (!FileSystem.exists(haxeXmlPath)) {
			File.saveContent(haxeXmlPath, _xmlHaxe.execute(context));
		}

		var workspaceXmlPath = Path.join([dotIdeaPath, "workspace.xml"]);
		if (!FileSystem.exists(workspaceXmlPath)) {
			File.saveContent(workspaceXmlPath, '<?xml version="1.0" encoding="UTF-8"?>\n<project version="4">\n</project>');
		}

		var modulesXmlPath = Path.join([dotIdeaPath, "modules.xml"]);
		File.saveContent(modulesXmlPath, _xmlModules.execute(context));
	}

	function createRun(path:String) {
		Log.info("SETUP IDEA RUN CONFIGURATIONS...");
		var rcPath = Path.join([path, ".idea", "runConfigurations"]);

		if (!FileSystem.exists(rcPath)) {
			FileSystem.createDirectory(rcPath);
		}

		for (module in _modules) {
			var ideaData:IdeaData = module.get("idea", IdeaData);
			if (ideaData != null) {
				for (run in ideaData.run) {
					var name = module.name;
					var context = {
						NAME: name,
						FILE_TO_RUN: Path.join([module.path, run.file])
					};
					var runConfigurationPath = Path.join([rcPath, '$name.xml']);
					var runConfigurationContent = _xmlRunConfig.execute(context);
					Log.trace('Run Configuration: $runConfigurationPath');
					File.saveContent(runConfigurationPath, runConfigurationContent);
				}
			}
		}
	}

	function isModule(libraryName:String):Bool {
		return Lambda.exists(_modules, function(m:Module) {
			return m.name == libraryName;
		});
	}

	function getModules(module:Module):Array<String> {
		var modules:Array<String> = [];
		var deps = module.config.getAllDependencies();
		for (dependencyId in deps.keys()) {
			if (isModule(dependencyId)) {
				modules.push(dependencyId);
			}
		}
		return modules;
	}

	function getExternalLibraries(module:Module):Array<IdeaLibraryInfo> {
		var libraries:Array<IdeaLibraryInfo> = [];
		var deps = module.config.getAllDependencies();
		for (dependencyId in deps.keys()) {
			var libraryInfo:IdeaLibraryInfo = _depCache.get(dependencyId);
			if(libraryInfo == null) {
				var dependencyValues:Array<String> = deps.get(dependencyId).split(";");
				var depVer = dependencyValues.shift();
				libraryInfo = new IdeaLibraryInfo(dependencyId, []);
				if (!isModule(dependencyId)) {
					var isGlobal = dependencyValues.indexOf("global") >= 0;
					var cp = Haxelib.classPath(dependencyId, isGlobal);
					libraryInfo.classPath.push(Haxelib.classPath(dependencyId, isGlobal));

					var makePluginPath = Path.join([Haxelib.libPath(dependencyId, isGlobal), "makeplugin"]);
					if(FileSystem.exists(makePluginPath)) {
						libraryInfo.classPath.push(makePluginPath);
					}
				}
				_depCache.set(dependencyId, libraryInfo);
			}
			// is NOT Module dependency
			if(libraryInfo.classPath.length > 0) {
				libraries.push(libraryInfo);
			}
		}
		return libraries;
	}

	static function openIdeaProject(path:String) {
		var ideaPath = getIdeaInstallPath();
		if(ideaPath != null) {
			if(CL.platform.isMac) {
				CL.execute("open", ["-a", Path.join([ideaPath, "Contents/MacOS/idea"]), "--args", path]);
			}
			else if(CL.platform.isWindows) {
				CL.execute("start", ["/b", Path.join([ideaPath, "bin/idea.exe"]), path]);
			}
			else if(CL.platform.isLinux) {
				// TODO:
			}
		}
		else {
			Log.info("IDEA executable is not found");
		}
	}

	static function getIdeaInstallPath() {
		var candidates = [];

		if(CL.platform.isMac) {
			var applicationsDirs = ["/Applications", Path.join([CL.getUserHome(), "Applications"])];
			for(applicationsDir in applicationsDirs) {
				if(FileSystem.exists(applicationsDir) && FileSystem.isDirectory(applicationsDir)) {
					var list = FileSystem.readDirectory(applicationsDir);
					for(appDir in list) {
						if(appDir.indexOf("IntelliJ IDEA") >= 0) {
							candidates.push(Path.join([applicationsDir, appDir]));
						}
					}
				}
			}
		}
		else if(CL.platform.isWindows) {
			var applicationsDirs = [
				Sys.getEnv("HOMEDRIVE") + "\\Program Files (x86)\\JetBrains",
				Sys.getEnv("HOMEDRIVE") + "\\Program Files\\JetBrains",
				Sys.getEnv("HOMEDRIVE") + "\\Program Files (x86)",
				Sys.getEnv("HOMEDRIVE") + "\\Program Files"
			];
			for(applicationsDir in applicationsDirs) {
				if(FileSystem.exists(applicationsDir) && FileSystem.isDirectory(applicationsDir)) {
					var list = FileSystem.readDirectory(applicationsDir);
					for(appDir in list) {
						if(appDir.indexOf("IntelliJ IDEA") >= 0) {
							candidates.push(Path.join([applicationsDir, appDir]));
						}
					}
				}
			}
		}

		if(candidates.length > 0) {
			candidates.sort(function (a:String, b:String) {
				return -Reflect.compare(a, b);
			});
			return candidates[0];
		}
		return null;
	}
}
