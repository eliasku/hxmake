package hxmake.haxelib;

class HaxelibPlugin extends Plugin {

	public var ext(default, null):HaxelibConfig;

	function new() {}

	override function apply(module:Module) {
		ext = module.getExtConfig("haxelib");
		if (ext.library != null && ext.library) {
			if (ext.updateJson == null) {
				ext.updateJson = true;
			}
			if (ext.installDev == null) {
				ext.installDev = true;
			}
		}
		module.task("haxelib", new HaxelibTask()).dependsOn("haxelib-dependencies");
		module.task("package-haxelib", new HaxelibPackageTask()).dependsOn("haxelib");
		module.task("submit-haxelib", new HaxelibSubmitTask()).dependsOn("package-haxelib");
		module.task("haxelib-dependencies", new HaxelibDependencies());
	}

	public static function readDependencies(module:Module):Map<String, String> {
		var deps = new Map<String, String>();
		for (k in module.config.dependencies.keys()) {
			var sections:Array<String> = module.config.dependencies.get(k).split(";");
			var params:String = sections.shift();
			if (params == "haxelib") {
				params = "";
			}
			else if (params.indexOf(HaxelibDependencies.HAXELIB_PREFIX) == 0) {
				params = params.substring(HaxelibDependencies.HAXELIB_PREFIX.length);
			}
			deps.set(k, params);
		}
		return deps;
	}

	public static function applyHaxelib(module:Module) {
		@:privateAccess module.apply(HaxelibPlugin);
	}
}
