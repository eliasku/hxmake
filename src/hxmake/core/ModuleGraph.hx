package hxmake.core;

import hxmake.cli.MakeLog;
import haxe.io.Path;
import hxmake.cli.FileUtil;

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

			// apply default initialization
			// TODO: move to internal plugin
			if (module.config.makePath.indexOf("make") < 0) {
				module.config.makePath.push("make");
			}
			if (module.name != "hxmake" && module.config.devDependencies.get("hxmake") == null) {
				module.config.devDependencies.set("hxmake", "haxelib;global");
			}
		}
	}

	public function printStructure() {
		MakeLog.info("Module structure:");
		for (module in modules) {
			if (module.parent == null) {
				printModuleStructure(module);
			}
		}
	}

	public function finish() {
		for (module in modules) {
			module.finish();
		}
	}

	function printModuleStructure(module:Module, pref:String = "") {
		var isRoot = module.parent == null;
		var left = isRoot ? "*-" : "--";
		var icon = "     ";

		var isMain = module.isMain;
		var isActive = module.isActive;
		if (isActive || isMain) {
			icon = isMain ? "[+]  " : "[^]  ";
		}

		MakeLog.info(icon + pref + left + " " + module.name + " @ " + module.path);
		var i = 0;
		for (child in module.children) {
			var sym = ++i == module.children.length ? "`" : "|";
			var indent = isRoot ? "" : "   ";
			printModuleStructure(child, pref + indent + sym);
		}
	}
}
