import hxmake.haxelib.HaxelibPlugin;
import hxmake.idea.IdeaPlugin;

using hxmake.haxelib.HaxelibPlugin;

class HxMake extends hxmake.Module {
	function new() {
		config.classPath = ["src", "tool"];

		apply(IdeaPlugin);
		apply(HaxelibPlugin);

		var cfg = library().config;
		cfg.version = "0.0.1";
		cfg.description = "Task automation for Haxe multi-module projects";
		cfg.url = "https://github.com/eliasku/hxmake";
		cfg.tags = ["haxe", "make", "build", "haxelib", "tools", "neko", "project", "module", "cross"];
		cfg.contributors = ["eliasku"];
		cfg.license = "MIT";
	}
}