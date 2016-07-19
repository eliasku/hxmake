package hxmake.haxelib;

class HaxelibPlugin extends Plugin {

	public var ext(default, null):HaxelibExt;

	function new() {}

	override function apply(module:Module) {
		ext = module.set("haxelib", new HaxelibExt());
		module.task("haxelib", new HaxelibTask()).dependsOn("haxelibDependencies");
		if(module.parent == null) {
			module.task("haxelibDependencies", new HaxelibDependencies());
		}
	}

	public static function library(module:Module):HaxelibExt {
		module.update("haxelib", function(data:HaxelibExt) {

			data.updateJson = true;
			data.installDev = true;

			data.config.name = module.name;

			if(module.config.classPath.length > 0) {
				data.config.classPath = module.config.classPath[0];
			}

			for(k in module.config.dependencies.keys()) {
				var sections:Array<String> = module.config.dependencies.get(k).split(";");
				var params = sections.shift();
				if(params == "haxelib") {
					params = "";
				}
				else if(params.indexOf("haxelib:") == 0) {
					params = params.substring("haxelib:".length);
				}
				data.config.dependencies.set(k, params);
			}
		});
		return module.get("haxelib", HaxelibExt);
	}
}
