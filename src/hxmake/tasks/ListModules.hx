package hxmake.tasks;

import hxmake.cli.MakeLog;

class ListModules extends Task {

	public function new() {
		name = "modules";
		description = "Prints modules in structure of project";
	}

	override public function run() {
		var modules = module.root.allModules;
		MakeLog.info("Module structure:");
		for (module in modules) {
			if (module.parent == null) {
				printModuleStructure(module);
			}
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

		MakeLog.info(icon + pref + left + " " + module.name + " @ " + module.path);
		var i = 0;
		for (child in module.children) {
			var sym = ++i == module.children.length ? "`" : "|";
			var indent = isRoot ? "" : "   ";
			printModuleStructure(child, pref + indent + sym);
		}
	}
}
