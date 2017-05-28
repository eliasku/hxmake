import hxmake.haxelib.HaxelibExt;
import hxmake.haxelib.HaxelibPlugin;
import hxmake.idea.IdeaPlugin;

using hxmake.haxelib.HaxelibPlugin;

class HxMake extends hxmake.Module {
	function new() {
		config.classPath = ["src", "tool"];

		apply(IdeaPlugin);
		apply(HaxelibPlugin);

		library(function(ext:HaxelibExt) {
			ext.config.version = "0.1.5";
			ext.config.description = "Task automation for Haxe multi-module projects";
			ext.config.url = "https://github.com/eliasku/hxmake";
			ext.config.tags = ["haxe", "make", "build", "haxelib", "tools", "neko", "project", "module", "cross"];
			ext.config.contributors = ["eliasku"];
			ext.config.license = "MIT";
			ext.config.releasenote = "see changelog";

			ext.pack.includes = ["src", "resources", "tool", "build.hxml", "haxelib.json", "run.n", "README.md"];
		});
	}
}