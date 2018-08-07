package hxmake.idea;

class IdeaPlugin extends Plugin {

	public var task(default, null):IdeaProjectTask;

	function new() {}

	override function apply(module:Module) {
		module.set("idea", new IdeaData());
		// if module is root
		if (module.parent == null) {
			task = new IdeaProjectTask();
			module.task("idea", task).dependsOn("haxelib");
		}
	}
}
