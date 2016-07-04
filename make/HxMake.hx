import hxmake.haxelib.HaxelibExt;
import hxmake.haxelib.HaxelibPlugin;
import hxmake.idea.IdeaPlugin;

using hxmake.haxelib.HaxelibPlugin;

class HxMake extends hxmake.Module {
	function new() {
		config.classPath = ["src", "tool"];
		config.authors = ["eliasku"];

		apply(IdeaPlugin);
		apply(HaxelibPlugin);

		// option #1
//		update("haxelib", function(ext:HaxelibExt) {
//			ext.library = new HaxeLibraryDeclaration();
//		});

		// option #2
		library();
	}
}