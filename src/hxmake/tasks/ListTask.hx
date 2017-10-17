package hxmake.tasks;

import hxmake.cli.MakeLog;
import hxmake.utils.MapTools;

using Lambda;

@:access(hxmake.Module)
class ListTask extends Task {

	public function new() {
		name = "tasks";
		description = "Prints list of available tasks";
	}

	override public function run() {
		var modules = project.modules;
		var map = new Map<String, Array<Task>>();
		for (module in modules) {
			var moduleTasks = module._tasks;
			for (name in moduleTasks.keys()) {
				MapTools.pushToValueArray(map, name, moduleTasks.get(name));
			}
		}

		var list = [for (name in map.keys()) name];
		list.sort(
			function(a:String, b:String) {
				return Reflect.compare(a, b);
			}
		);

		if (list.length > 0) {
			MakeLog.info("Project tasks:");
			for (taskName in list) {
				var task:Task = map.get(taskName)[0];
				var desc = task.description;
				if (desc == null || desc.length == 0) desc = "No description";
				var availableTasks:Array<Task> = map.get(taskName);
				var registeredInModules = [for (task in availableTasks) task.module.name];
				MakeLog.info('\t> $taskName - $desc (${registeredInModules.join(", ")})');
			}
		}
		else {
			MakeLog.warning("Project tasks not found");
		}
	}
}
