package hxmake.core;

import hxmake.cli.CL;
import hxmake.cli.MakeLog;
import hxmake.Task;

@:final
@:access(hxmake.Task)
class TaskQueue {

	var _queue:Array<TaskNode>;
	var _runner:TaskRunner;

	public function new(queue:Array<TaskNode>) {
		_queue = queue;
		// TODO: as dependency
		_runner = new TaskRunner(MakeLog.logger);
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