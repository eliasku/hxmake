import hxmake.haxelib.HaxelibExt;
import hxmake.haxelib.HaxelibPlugin;
import hxmake.idea.IdeaPlugin;
import hxmake.test.TestTask;

using hxmake.haxelib.HaxelibPlugin;

class HxMake extends hxmake.Module {
	function new() {
		config.classPath = ["src", "tool"];
		config.testPath = ["test"];
		config.devDependencies = [
			"utest" => "haxelib"
		];

		apply(IdeaPlugin);
		apply(HaxelibPlugin);

		this.library(function(ext:HaxelibExt) {
			ext.config.version = "0.2.6";
			ext.config.description = "Task automation for Haxe multi-module projects";
			ext.config.url = "https://github.com/eliasku/hxmake";
			ext.config.tags = ["haxe", "make", "build", "haxelib", "tools", "neko", "project", "module", "cross"];
			ext.config.contributors = ["eliasku"];
			ext.config.license = "MIT";
			ext.config.releasenote = "see changelog";

			ext.pack.includes = ["src", "resources", "tool", "build.hxml", "haxelib.json", "run.n", "README.md", "CHANGELOG.md"];
		});

		var test = new TestTask();
		test.targets = ["neko"];
		test.libraries = ["hxmake"];
		task("test", test);
	}
}