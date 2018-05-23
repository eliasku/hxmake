package hxmake.core;

import hxmake.haxelib.HaxelibPlugin;
import hxmake.idea.IdeaPlugin;
import hxmake.test.UTestPlugin;

@:final
@:access(hxmake.Module)
class ModuleGraph {

	var _modules(default, null):Array<Module>;

	public function new(modules:Array<Module>) {
		_modules = modules;
	}

	public function initialize() {
		for (module in _modules) {
			module.initialize();
			if (module.packageData.init != null) {
				var initList = module.packageData.init;
				for (initClass in initList) {
					Type.createInstance(Type.resolveClass(initClass), [module]);
				}
			}
			var taskMap = module.packageData.tasks;
			if (taskMap != null) {
				for (taskName in taskMap.keys()) {
					var taskClass = taskMap.get(taskName);
					var task = Type.createInstance(Type.resolveClass(taskClass), []);
					module.task(taskName, task);
				}
			}
			initializeBuiltIn(module);
		}
	}

	public function configure() {
		for (module in _modules) {
			module.configure();
		}
	}

	public function finish() {
		for (module in _modules) {
			module.finish();
		}
	}

	static function initializeBuiltIn(module:Module) {
		// apply default initialization
		// TODO: move to internal plugin
		var config:ModuleConfig = module.requireOptionalExtConfig("config");

		// TODO: ddefault script path with check
//		if (config.makePath == null) {
//			config.makePath = [];
//		} && config.makePath.indexOf("make") < 0) {
//			module.config.makePath.push("make");
//		}

		if (module.name != "hxmake") {
			if (config.devDependencies == null) {
				config.devDependencies = {};
			}
			if (!config.devDependencies.exists("hxmake")) {
				config.devDependencies.set("hxmake", "haxelib;global");
			}
		}

		if (module.getExtConfig("haxelib") != null) {
			HaxelibPlugin.applyHaxelib(module);
		}

		if (module.getExtConfig("idea") != null) {
			IdeaPlugin.applyIdea(module);
		}

		if (module.getExtConfig("utest") != null) {
			UTestPlugin.apply(module);
		}
	}
}
