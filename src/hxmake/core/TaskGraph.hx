package hxmake.core;

import hxmake.cli.MakeLog;
import hxmake.cli.CL;

@:final
@:access(hxmake.Module)
@:access(hxmake.Task)
class TaskGraph {

	var _nodes:Array<TaskNode> = [];
	var _modules:Array<Module>;
	var _runTasks:Array<String>;
	var _orderData:Map<String, String> = new Map();

	function new(runTasks:Array<String>, modules:Array<Module>) {
		_modules = modules;
		_runTasks = runTasks;
	}

	public function build() {
		_runTasks = resolveDependencies(_runTasks, _modules);
		configureTasks();
		resolveOrder();
	}

	public function printTasks() {
		MakeLog.info("Task dependency order: ");
		for (node in _nodes) {
			MakeLog.info("\t" + node.task.module.name + "." + node.name);
		}
	}

	public function run() {
		for (node in _nodes) {
			var task = node.task;
			if (task.enabled) {
				CL.workingDir.push(task.module.path);
				@:privateAccess task._run();
				CL.workingDir.pop();
			}
		}
	}

	static function resolveDependencies(requiredTasks:Array<String>, modules:Array<Module>):Array<String> {
		var runTasks = requiredTasks.copy();
		var process:Bool = true;
		while (process) {
			process = false;
			for (module in modules) {
				var tasks = module._tasks;
				for (taskId in tasks.keys()) {
					var ct:Task = tasks.get(taskId);
					if (runTasks.indexOf(taskId) >= 0) {
						for (depTask in ct.__depends) {
							if (runTasks.indexOf(depTask) < 0) {
								process = true;
								runTasks.push(depTask);
							}
						}
					}
				}
			}
		}
		return runTasks;
	}

	function configureTasks() {
		for (module in _modules) {
			var tasks = module._tasks;
			CL.workingDir.push(module.path);
			for (taskId in tasks.keys()) {
				if (_runTasks.indexOf(taskId) >= 0) {
					var task:Task = tasks.get(taskId);
					task._configure();
					_nodes.push(new TaskNode(taskId, task));
				}
			}
			CL.workingDir.pop();
		}
	}

	function resolveOrder() {
		for (node in _nodes) {
			var task = node.task;
			for (taskAfter in task.__before) {
				_orderData.set(node.name, taskAfter);
			}
			for (taskBefore in task.__after) {
				_orderData.set(taskBefore, node.name);
			}
		}

		_nodes.sort(orderComparator);
	}

	function orderComparator(a:TaskNode, b:TaskNode) {
		var after = _orderData.get(b.name);
		var prevAfter:String;
		while (after != null) {
			if (a.name == after) {
				return 1;
			}
			after = _orderData.get(after);
		}
		return -1;
	}
}