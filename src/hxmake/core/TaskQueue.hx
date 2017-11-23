package hxmake.core;

import hxmake.cli.CL;
import hxmake.cli.logging.Logger;
import hxmake.Task;

@:final
@:access(hxmake.Task)
class TaskQueue {

	var _queue:Array<TaskNode>;
	var _runner:TaskRunner;

	public function new(queue:Array<TaskNode>, logger:Logger) {
		_queue = queue;
		_runner = new TaskRunner(logger);
	}

	public function configure():Void {
		var wd = CL.workingDir;
		for (node in _queue) {
			wd.with(node.module.path, function() {
				_runner.configure(node.task);
			});
		}
	}

	public function run() {
		var wd = CL.workingDir;
		for (node in _queue) {
			wd.with(node.module.path, function() {
				_runner.run(node.task);
			});
		}
	}
}