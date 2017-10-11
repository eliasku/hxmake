package hxmake.core;

import haxe.io.Path;
import hxmake.cli.FileUtil;
import hxmake.cli.MakeLog;

@:final
@:access(hxmake.Module)
class ModuleGraph {

	public var modules(default, null):Array<Module>;

	function new() {
		modules = CompiledProjectData.getModules();
		MakeLog.trace("[ModuleGraph] input modules: " + modules.map(function(m:Module) {return m.name;}).join(","));
	}

	public function resolveHierarchy() {
		var connections = CompiledProjectData.getConnectionsList();
		for (connection in connections) {
			for (parent in modules) {
				if (FileUtil.pathEquals(parent.path, connection.parentPath)) {
					for (childPath in connection.childPath) {
						for (child in modules) {
							if (FileUtil.pathEquals(child.path, childPath)) {
								parent.addSubModule(child);
							}
						}
					}
				}
			}
		}
	}

	public function prepare(project:Project) {
		var runningInDirectory = Path.directory(Sys.getCwd());
		for (module in modules) {
			module.project = project;
			module.isMain = FileUtil.pathEquals(module.path, runningInDirectory);
		}
	}

	public function initialize() {
		for (module in modules) {
			module.__initialize();
			initializeBuiltIn(module);
		}
	}

	public function finish() {
		for (module in modules) {
			module.finish();
		}
	}

	function initializeBuiltIn(module:Module) {
		// apply default initialization
		// TODO: move to internal plugin
		if (module.config.makePath.indexOf("make") < 0) {
			module.config.makePath.push("make");
		}

		if (module.name != "hxmake" && module.config.devDependencies.get("hxmake") == null) {
			module.config.devDependencies.set("hxmake", "haxelib;global");
		}

		if (module.isMain) {
			module.task("tasks", new hxmake.tasks.ListTask());
			module.task("modules", new hxmake.tasks.ListModules());
		}
	}
}
