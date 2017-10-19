package hxmake.core;

import hxmake.cli.CL;
import hxmake.cli.MakeLog;
import hxmake.Task;

@:final
@:access(hxmake.Task)
class TaskQueue {

	var _queue:Array<TaskNode>;

	public function new(queue:Array<TaskNode>) {
		_queue = queue;
	}

	// TODO: move to "Printer" utility
	public function print() {
		if (_queue.length > 0) {
			MakeLog.info("Tasks order: ");
			for (node in _queue) {
				MakeLog.info('\t${node.name} for ${node.module.name}');
			}
		}
		else {
			MakeLog.warning("No tasks for execution");
		}
	}

	public function configure():Void {
		var wd = CL.workingDir;
		for (node in _queue) {
			wd.with(node.module.path, function() {
				node.task._configure();
			});
		}
	}

	public function run() {
		var wd = CL.workingDir;
		for (node in _queue) {
			if (node.task.enabled) {
				wd.with(node.module.path, function() {
					node.task._run();
				});
			}
		}
	}
}