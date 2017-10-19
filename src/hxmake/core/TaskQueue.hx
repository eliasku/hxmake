package hxmake.core;

import hxmake.cli.CL;
import hxmake.Task;

@:final
@:access(hxmake.Task)
class TaskQueue {

	var _queue:Array<TaskNode>;

	public function new(queue:Array<TaskNode>) {
		_queue = queue;
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