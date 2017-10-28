package hxmake.tasks;

class ListModules extends Task {

	public function new() {
		name = "modules";
		description = "Prints modules in structure of project";
	}

	override public function run() {
		var roots = project.modules.filter(function(module:Module) {
			return module.parent == null;
		});

		project.logger.info('Project start path: ${project.workingDir}');
		project.logger.info("Module structure:");
		for (root in roots) {
			printModuleStructure(root);
		}
	}

	function printModuleStructure(module:Module, pref:String = "") {
		var isRoot = module.parent == null;
		var left = isRoot ? "*-" : "--";
		var icon = "     ";

		var isMain = module.isMain;
		var isActive = module.isActive;
		if (isActive || isMain) {
			icon = isMain ? "[+]  " : "[^]  ";
		}

		project.logger.info(icon + pref + left + " " + module.name + " @ " + module.path);
		var i = 0;
		var children = module.children;
		for (child in children) {
			var sym = ++i == children.length ? "`" : "|";
			var indent = isRoot ? "" : "   ";
			printModuleStructure(child, pref + indent + sym);
		}
	}
}
