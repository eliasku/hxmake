package hxmake.core;

import hxmake.cli.MakeLog;
import hxmake.Task;
import hxmake.cli.CL;

@:final
@:access(hxmake.Module)
@:access(hxmake.Task)
class TaskGraph {
	var _modules:Array<Module>;
	var _runTasks:Array<String>;
	var _taskNodes:Array<TaskNode> = [];

	function new(args:Array<String>, modules:Array<Module>) {
		_modules = modules;
		_runTasks = getTasksNameFromArgs(args);
	}

	static function getTasksNameFromArgs(args:Array<String>):Array<String> {
		var result:Array<String> = [];
		for (arg in args) {
			if (arg.charAt(0) != "-") {
				result.push(arg);
			}
		}
		return result;
	}

	public function build() {
		var initialTasks:Array<TaskNode> = findInitialTasks(_runTasks, _modules);
		var allTasksToRunUnordered:Array<TaskNode> = findDependedTasks(initialTasks, _modules);
		var allTasksToRunOrdered:Array<TaskNode> = resolveTasksOrder(allTasksToRunUnordered);
		_taskNodes = allTasksToRunOrdered;
		configureTasks();
	}

	public function printTasks() {
		MakeLog.info("Task dependency order: ");
		for (taskNode in _taskNodes) {
			MakeLog.info("\t" + taskNode.module.name + "." + taskNode.name);
		}
	}

	public function run() {
		for (taskNode in _taskNodes) {
			var task = taskNode.task;
			if (task.enabled) {
				CL.workingDir.push(task.module.path);
				@:privateAccess task._run();
				CL.workingDir.pop();
			}
		}
	}

	static function findInitialTasks(tasksNames:Array<String>, modules:Array<Module>):Array<TaskNode> {
		var result:Array<TaskNode> = [];
		var atLeastOneFound:Bool = false;
		for (taskName in tasksNames) {
			atLeastOneFound = false;
			for (module in modules) {
				var task:Task = module.getTask(taskName);
				if (task != null) {
					result.push(new TaskNode(taskName, task));
					atLeastOneFound = true;
				}
			}
			if (!atLeastOneFound) {
				throw 'Task with name `${taskName}` not found.';
			}
		}
		return result;
	}

	static function findDependedTasks(initialTasks:Array<TaskNode>, modules:Array<Module>):Array<TaskNode> {
		var tasks:Array<TaskNode> = initialTasks.copy();
		for (task in tasks) {
			findDependedTask(task, tasks);
		}
		return tasks;
	}

	static function findDependedTask(taskNode:TaskNode, addedTasks:Array<TaskNode>):Void {
		var currentTask:Task = taskNode.task;
		var taskModule:Module = taskNode.module;
		for (depended in currentTask.__depends) {
			var alreadyExists:Bool = false;
			for (addedTask in addedTasks) {
				if (addedTask.name == depended && addedTask.module == taskModule) {
					alreadyExists = true;
					break;
				}
			}
			if (!alreadyExists) {
				var newTask:Task = taskModule.getTask(depended);
				if (newTask == null) {
					throw 'Task with name `${depended}` not found in module `${taskModule.name}`. Specified as dependency to `${taskNode.name}`';
				}
				var newTaskDef:TaskNode = new TaskNode(depended, newTask);
				addedTasks.push(newTaskDef);
				findDependedTask(newTaskDef, addedTasks);
			}
		}
	}

	static function resolveTasksOrder(tasks:Array<TaskNode>):Array<TaskNode> {
		tasks = tasks.copy();
		var tasksLength:Int = tasks.length;

		var allTasksIndexes:Map<TaskNode, Int> = new Map<TaskNode, Int>();
		for (i in 0...tasksLength) {
			allTasksIndexes.set(tasks[i], i);
		}

		var executionOrderRelations:Array<Array<Int>> = new Array<Array<Int>>();
		for (i in 0...tasksLength) {
			executionOrderRelations.push(new Array<Int>());
			for (j in 0...tasksLength) {
				executionOrderRelations[i][j] = 0;
			}
		}

		// Manadatory execution list flow order
		for (task in tasks) {
			var taskIndex:Int = allTasksIndexes.get(task);
			for (depended in task.task.__depends) {
				var dependedTask:TaskNode = null;
				for (it in tasks) {
					if (it.name == depended && task.task.module == it.task.module) {
						dependedTask = it;
						break;
					}
				}
				if (dependedTask == null) {
					throw 'Illegal state. Task `${depended}` added as dependency to task `${task.name}` but received null task value.`';
				}
				var relationIndex:Int = allTasksIndexes.get(dependedTask);
				executionOrderRelations[taskIndex][relationIndex] = 1;
			}
		}

		// Optional execution list flow order (after)
		for (task in tasks) {
			var taskIndex:Int = allTasksIndexes.get(task);
			for (runAfter in task.task.__after) {
				var runAfterTask:TaskNode = null;
				for (it in tasks) {
					if (it.name == runAfter && task.task.module == it.task.module) {
						runAfterTask = it;
						break;
					}
				}
				if (runAfterTask == null) {
					continue;
				}
				var relationIndex:Int = allTasksIndexes.get(runAfterTask);
				executionOrderRelations[taskIndex][relationIndex] = 1;
			}
		}

		// Optional execution list flow order (before)
		for (task in tasks) {
			var taskIndex:Int = allTasksIndexes.get(task);
			for (runBefore in task.task.__before) {
				var runBeforeTask:TaskNode = null;
				for (it in tasks) {
					if (it.name == runBefore && task.task.module == it.task.module) {
						runBeforeTask = it;
						break;
					}
				}
				if (runBeforeTask == null) {
					continue;
				}
				var relationIndex:Int = allTasksIndexes.get(runBeforeTask);
				executionOrderRelations[relationIndex][taskIndex] = 1;
			}
		}

		var executionOrder:Array<TaskNode> = [];
		var usage:Array<Bool> = new Array<Bool>();
		for (i in 0...tasksLength) usage.push(true);
		for (i in 0...tasksLength) {
			for (j in 0...tasksLength) {
				if (!usage[j]) {
					continue;
				}
				var containsOnlyZeros:Bool = true;
				for (k in 0...tasksLength) {
					if (usage[k] && executionOrderRelations[j][k] == 1) {
						containsOnlyZeros = false;
						break;
					}
				}
				if (containsOnlyZeros) {
					// Task without relations.
					executionOrder.push(tasks[j]);
					usage[j] = false;
				}
			}
		}

		if (usage.indexOf(true) != -1) {
			var cycling:Array<TaskNode> = [];
			for (i in 0...tasksLength) {
				if (usage[i]) {
					cycling.push(tasks[i]);
				}
			}
			var cyclingWarn:String = cycling.map(function(taskDef:TaskNode):String {
				return '${taskDef.task.module.name}.${taskDef.name}';
			}).join(", ");
			throw 'There are cycling dependencies or run order between next tasks: `${cyclingWarn}`';
		}

		return executionOrder;
	}

	function configureTasks():Void {
		for (taskDefinition in _taskNodes) {
			CL.workingDir.push(taskDefinition.task.module.path);
			taskDefinition.task._configure();
			CL.workingDir.pop();
		}
	}
}