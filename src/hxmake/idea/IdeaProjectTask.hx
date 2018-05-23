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
	var _hideIml:Bool;

	public function new() {}

	override public function run() {
		var rootIdeaData:IdeaData = module.getExtConfig("idea");
		_hideIml = rootIdeaData != null && rootIdeaData.hideIml;

		_idea = new IdeaContext();
		_modules = module.getSubModules(true, false);
		_rootModule = module;

		FileUtil.ensureDirectory(_rootModule.path, ".idea");
		FileUtil.ensureDirectory(_rootModule.path, ".idea/modules");

		for (mod in _modules) {
			createModule(mod);
		}
		createProject(_rootModule.path);
		createRun(_rootModule.path);
		_idea.openProject(_rootModule.path);
	}

	function createModule(module:Module) {

		var ideaData:IdeaData = module.getExtConfig("idea");
		if (ideaData == null) {
			return;
		}

		var modules = getModules(module);
		var libraries = getExternalLibraries(module);

		var classPath = module.config.classPath;
		if (classPath == null) {
			classPath = [];
		}

		var testPath = [];
		if (module.config.testPath != null) testPath = testPath.concat(module.config.testPath);
		if (module.config.makePath != null) testPath = testPath.concat(module.config.makePath);
		if (module.packageData.makeplugin != null && module.packageData.makeplugin.src != null) {
			for (mpsrc in module.packageData.makeplugin.src) {
				if (classPath.indexOf(mpsrc) < 0 && FileUtil.dirExists(Path.join([module.path, mpsrc]))) {
					testPath.push(mpsrc);
				}
			}
		}

		var context:IdeaTemplateContext = {
			moduleName: module.name,
			moduleDependencies: modules,
			moduleLibraries: libraries,
			sourceDirs: classPath,
			testDirs: testPath,
			testResDirs: [],
			resDirs: [],
			flexSdkName: getFlexSDKName(),
			haxeSdkName: getHaxeSDKName(),
			buildConfig: 1,
			projectPath: "",
			projectTarget: "",
			moduleDir: "$MODULE_DIR$",
			skipCompilation: true
		};

		if(_hideIml) {
			context.moduleDir = module.path;
		}

		if (ideaData.resources != null) {
			context.resDirs = ideaData.resources;
		}

		if (ideaData.testResources != null) {
			context.testResDirs = ideaData.testResources;
		}

		if (ideaData.hxml != null) {
			var buildHxml = ideaData.hxml;
			var p = Path.join([context.moduleDir, buildHxml]);
			var t = "Flash";
			context.buildConfig = 1;
			context.skipCompilation = false;
			context.projectPath = '<option name="hxmlPath" value="$p" />';
			context.projectTarget = '<option name="haxeTarget" value="$t" />';
		}
		else if (ideaData.lime != null) {
			var limeProjectPath = ideaData.lime;
			var p = Path.join([context.moduleDir, limeProjectPath]);
			var t = "Flash";
			context.buildConfig = 3;
			context.projectPath = '<option name="openFLPath" value="$p" />';
			context.projectTarget = '<option name="openFLTarget" value="$t" />';
		}

		var iml = _idea.iml.execute(context);
		project.logger.info("Writing " + module.name + ".iml");
		FileUtil.deleteFiles(module.path, "*.iml");
		if(_hideIml) {
			File.saveContent(Path.join([this.module.path, '.idea/modules/${module.name}.iml']), iml);
		}
		else {
			File.saveContent(Path.join([module.path, '${module.name}.iml']), iml);
		}
	}

	function getHaxeSDKName():String {
		return _idea.getSdkName(IdeaSdkType.HAXE, "Haxe 3.4.4");
	}

	function getFlexSDKName():String {
		return _idea.getSdkName(IdeaSdkType.FLEX, "AIR_SDK");
	}

	function createProject(path:String) {
		project.logger.info("SETUP IDEA PROJECT...");

		var rootIdeaData:IdeaData = module.getExtConfig("idea");
		var hideIml = rootIdeaData != null && rootIdeaData.hideIml;

		var context = {
			modules: [],
			haxeSdkName: getHaxeSDKName()
		};

		for (module in _modules) {
			var ideaData:IdeaData = module.getExtConfig("idea");
			if (ideaData == null) {
				continue;
			}

			var modulePath:String = module.path.replace(path, "");
			var moduleData = {
				path: '$modulePath/${module.name}.iml',
				groupAddon: ""
			};
			if(hideIml) {
				moduleData.path = '.idea/modules/${module.name}.iml';
			}
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

		var jsonSchema = Path.join([dotIdeaPath, "jsonSchemas.xml"]);
		File.saveContent(jsonSchema, _idea.xmlJsonSchemas.execute(context));

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
			var ideaData:IdeaData = module.getExtConfig("idea");
			if (ideaData != null && ideaData.run != null) {
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
			return m.name == libraryName && m.getExtConfig("idea") != null;
		});
	}

	function getModules(module:Module):Array<String> {
		var modules:Array<String> = [];
		var deps = Module.getAllDependenciesFromConfig(module.config);
		for (dependencyId in deps.keys()) {
			if (isModule(dependencyId)) {
				modules.push(dependencyId);
			}
		}
		return modules;
	}

	function getExternalLibraries(module:Module):Array<IdeaLibraryInfo> {
		var libraries:Array<IdeaLibraryInfo> = [];
		var deps = Module.getAllDependenciesFromConfig(module.config);
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
