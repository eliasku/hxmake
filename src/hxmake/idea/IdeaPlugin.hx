package hxmake.idea;

import haxe.DynamicAccess;

class IdeaPlugin extends Plugin {

	function new() {}

	override function apply(module:Module) {
		// if module is root
		if (module.parent == null) {
			module.task("idea", new IdeaProjectTask()).dependsOn("haxelib");
		}
	}

	public static function applyIdea(module:Module) {
		@:privateAccess module.apply(IdeaPlugin);
	}
}
