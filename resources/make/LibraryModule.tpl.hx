import hxmake.haxelib.HaxelibExt;
import hxmake.haxelib.HaxelibPlugin;
import hxmake.idea.IdeaPlugin;
import hxmake.test.TestTask;

using hxmake.haxelib.HaxelibPlugin;

class CLASS_NAME extends hxmake.Module {
	function new() {
		config.classPath = ["src"];
		config.testPath = ["test"];
		config.devDependencies = [
			"utest" => "haxelib"
		];

		apply(IdeaPlugin);
		apply(HaxelibPlugin);

		library(function(library:HaxelibExt) {
			// modify `library` configuration here...
		});

		var test = new TestTask();
		test.targets = ["neko"];
		// Modify configuration here
		task("test", test);
	}
}