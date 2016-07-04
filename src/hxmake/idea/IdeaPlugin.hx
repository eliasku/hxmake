package hxmake.idea;

class IdeaPlugin extends Plugin {

	function new() {}

	override function apply(module:Module) {
		module.set("idea", new IdeaData());
		// if module is root
		if(module.parent == null) {
			module.task("idea", new IdeaProjectTask()).dependsOn("haxelib");
		}
	}
}
