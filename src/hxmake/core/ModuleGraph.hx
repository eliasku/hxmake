package hxmake.core;

@:final
@:access(hxmake.Module)
class ModuleGraph {

	var _modules(default, null):Array<Module>;

	public function new(modules:Array<Module>) {
		_modules = modules;
	}

	public function initialize() {
		for (module in _modules) {
			module.__initialize();
			initializeBuiltIn(module);
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
		if (module.config.makePath.indexOf("make") < 0) {
			module.config.makePath.push("make");
		}

		if (module.name != "hxmake" && module.config.devDependencies.get("hxmake") == null) {
			module.config.devDependencies.set("hxmake", "haxelib;global");
		}
	}
}
