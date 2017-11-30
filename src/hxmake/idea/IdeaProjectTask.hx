package hxmake.idea;

import haxe.io.Path;
import hxmake.cli.FileUtil;
import hxmake.utils.CachedHaxelib;
import hxmake.utils.Haxelib;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class IdeaProjectTask extends Task {

	var _idea:IdeaContext;
	var _modules:Array<Module>;
	var _rootModule:Module;
	var _depCache:Map<String, IdeaLibraryInfo> = new Map();

	public function new() {}

	override public function run() {
		_idea = new IdeaContext();
		_modules = module.getSubModules(true, false);
		_rootModule = module;
		for (mod in _modules) {
			createModule(mod);
		}
		createProject(_rootModule.path);
		createRun(_rootModule.path);
		_idea.openProject(_rootModule.path);
	}

	function createModule(module:Module) {

		var ideaData:IdeaData = module.get("idea", IdeaData);
		if (ideaData == null) {
			return;
		}

		var modules = getModules(module);
		var libraries = getExternalLibraries(module);

		var testPath = module.config.testPath.concat(module.config.makePath);
		if (FileUtil.dirExists(Path.join([module.path, "makeplugin"]))) {
			testPath.push("makeplugin");
		}

		var context = {
			moduleName: module.name,
			moduleDependencies: modules,
			moduleLibraries: libraries,
			sourceDirs: module.config.classPath,
			testDirs: testPath,
			flexSdkName: getFlexSDKName(),
			haxeSdkName: getHaxeSDKName(),
			buildConfig: 1,
			projectPath: "",
			projectTarget: "",
			skipCompilation: true
		};

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

		var iml = _idea.iml.execute(context);
		project.logger.info("Writing " + module.name + ".iml");
		FileUtil.deleteFiles(module.path, "*.iml");
		File.saveContent(Path.join([module.path, '${module.name}.iml']), iml);
	}

	function getHaxeSDKName():String {
		return _idea.getSdkName(IdeaSdkType.HAXE, "Haxe 3.4.4");
	}

	function getFlexSDKName():String {
		return _idea.getSdkName(IdeaSdkType.FLEX, "AIR_SDK");
	}

	function createProject(path:String) {
		project.logger.info("SETUP IDEA PROJECT...");

		var context = {
			modules: [],
			haxeSdkName: getHaxeSDKName()
		};

		for (module in _modules) {
			var ideaData:IdeaData = module.get("idea", IdeaData);
			if (ideaData == null) {
				continue;
			}

			var modulePath:String = module.path.replace(path, "");
			var moduleData = {
				path: '$modulePath/${module.name}.iml',
				groupAddon: ""
			};
			context.modules.push(moduleData);
			if (ideaData.group != null) {
				moduleData.groupAddon = ' group="${ideaData.group}" ';
			}
		}


		var dotIdeaPath = FileUtil.ensureDirectory(path, ".idea");
		var tempOutPath = FileUtil.ensureDirectory(path, "out");
		var haxeXmlPath = Path.join([dotIdeaPath, "haxe.xml"]);
		if (!FileSystem.exists(haxeXmlPath)) {
			File.saveContent(haxeXmlPath, _idea.xmlHaxe.execute(context));
		}

		var workspaceXmlPath = Path.join([dotIdeaPath, "workspace.xml"]);
		if (!FileSystem.exists(workspaceXmlPath)) {
			File.saveContent(workspaceXmlPath, '<?xml version="1.0" encoding="UTF-8"?>\n<project version="4">\n</project>');
		}

		var modulesXmlPath = Path.join([dotIdeaPath, "modules.xml"]);
		File.saveContent(modulesXmlPath, _idea.xmlModules.execute(context));

		var miscXml = Path.join([dotIdeaPath, "misc.xml"]);
		File.saveContent(miscXml, _idea.xmlMisc.execute(context));
	}

	function createRun(path:String) {
		project.logger.info("SETUP IDEA RUN CONFIGURATIONS...");
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
					var runConfigurationContent = _idea.xmlRunConfig.execute(context);
					project.logger.trace('Run Configuration: $runConfigurationPath');
					File.saveContent(runConfigurationPath, runConfigurationContent);
				}
			}
		}
	}

	function isModule(libraryName:String):Bool {
		return Lambda.exists(_modules, function(m:Module) {
			return m.name == libraryName && m.get("idea", IdeaData) != null;
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
			if (libraryInfo == null) {
				var dependencyValues:Array<String> = deps.get(dependencyId).split(";");
				var depVer = dependencyValues.shift();
				libraryInfo = new IdeaLibraryInfo(dependencyId, []);
				if (!isModule(dependencyId)) {
					var isGlobal = dependencyValues.indexOf("global") >= 0;
					var cp = CachedHaxelib.classPath(dependencyId, isGlobal);
					libraryInfo.classPath.push(cp);

					var makePluginPath = Path.join([Haxelib.resolveRootPathFromClassPath(cp), "makeplugin"]);
					if (FileSystem.exists(makePluginPath)) {
						libraryInfo.classPath.push(makePluginPath);
					}
				}
				_depCache.set(dependencyId, libraryInfo);
			}
			// is NOT Module dependency
			if (libraryInfo.classPath.length > 0) {
				libraries.push(libraryInfo);
			}
		}
		return libraries;
	}
}
