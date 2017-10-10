package hxmake.tasks;

import hxmake.cli.MakeLog;

using Lambda;

class ListTask extends Task {

	public function new() {
		name = "tasks";
		description = "Print list of available tasks";
	}

	override public function configure() {

	}

	override public function run() {
		var modules = module.root.allModules;
		var map = new Map<String, Array<Task>>();
		for (module in modules) {
			var moduleTasks:Map<String, Task> = @:privateAccess module._tasks;
			for (name in moduleTasks.keys()) {
				var task:Task = moduleTasks.get(name);
				//if (task.name != null) {
				var con:Array<Task> = map.get(name);
				if (con == null) {
					con = [];
					map.set(name, con);
				}
				con.push(task);
				//}
			}
		}

		var list = [for (name in map.keys()) name];
		list.sort(
			function(a:String, b:String) {
				return Reflect.compare(a, b);
			}
		);

		for (taskName in list) {
			var task = map.get(taskName)[0];
			var desc = task.description;
			if (desc == null || desc.length == 0) desc = "No description";
			var ll = map.get(taskName);
			var inModules = [];
			for (l in ll) {
				inModules.push(l.module.name);
			}
			MakeLog.info('> $taskName - $desc (${inModules.join(", ")})');
		}
	}
}
