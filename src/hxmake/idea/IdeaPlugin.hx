package hxmake.idea;

class IdeaPlugin extends Plugin {

	function new() {}

	// `configurator` will be called in root module
	override function apply(module:Module, ?configurator:IdeaProjectTask -> Void) {
		module.set("idea", new IdeaData());
		// if module is root
		if (module.parent == null) {
			var task = new IdeaProjectTask();
			if (configurator != null) configurator(task);
			module.task("idea", task).dependsOn("haxelib");
		}
	}
}
