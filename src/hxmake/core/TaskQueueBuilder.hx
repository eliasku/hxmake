package hxmake.core;

using hxmake.utils.ArrayTools;

@:final
class TaskQueueBuilder {

	var _nodes:Array<TaskNode>;
	var _graph:TaskGraph;

	public function new() {
	}

	public static function createNodeList(modules:Array<Module>, tasks:Array<String>):Array<TaskNode> {
		return new TaskQueueBuilder().build(new TaskGraph(modules), tasks);
	}

	public function build(graph:TaskGraph, tasks:Array<String>):Array<TaskNode> {
		_nodes = [];
		_graph = graph;
		var roots = graph.requireTasks(tasks);
		var allTasksToRunUnordered = findDependedTasks(roots);
		var allTasksToRunOrdered = resolveTasksOrder(allTasksToRunUnordered);
		return allTasksToRunOrdered;
	}

	function findDependedTasks(initialTasks:Array<TaskNode>):Array<TaskNode> {
		var tasks = initialTasks.copy();
		for (task in initialTasks) {
			findTaskDependencies(task, tasks);
		}
		return tasks;
	}

	@:access(hxmake.Task)
	function findTaskDependencies(taskNode:TaskNode, outNodes:Array<TaskNode>):Array<TaskNode> {
		// find same task in module dependencies
		var dependedModules = taskNode.module.getSubModules(false, true);
		var nodes:Array<TaskNode> = [];
		nodes.pushRangeUnique(_graph.getNodesForModules(dependedModules, taskNode.name), outNodes);

		// find dependencies
		dependedModules.push(taskNode.module);
		for (depended in taskNode.task.__depends) {
			nodes.pushRangeUnique(requireDependedNodes(taskNode, depended, dependedModules), outNodes);
		}

		outNodes.pushRangeUnique(nodes);
		for (node in nodes) {
			findTaskDependencies(node, outNodes);
		}
		return outNodes;
	}

	function requireDependedNodes(target:TaskNode, depended:String, dependedModules:Array<Module>):Array<TaskNode> {
		var nodes = _graph.getNodesForModules(dependedModules, depended);
		if (nodes.length == 0) {
			throw 'Task with name `${depended}` not found in module `${target.module.name}`. Specified as dependency to `${target.name}`';
		}
		return nodes;
	}

	@:access(hxmake.Task)
	static function resolveTasksOrder(tasks:Array<TaskNode>):Array<TaskNode> {
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
				var dependedTasks:Array<TaskNode> = [];
				for (it in tasks) {
					if (checkTaskWithDeps(it, task, depended)) {
						dependedTasks.push(it);
					}
				}
				if (dependedTasks.length == 0) {
					throw 'Illegal state. Task `${depended}` added as dependency to task `${task.name}` but received null task value.`';
				}
				for (dependedTask in dependedTasks) {
					var relationIndex:Int = allTasksIndexes.get(dependedTask);
					executionOrderRelations[taskIndex][relationIndex] = 1;
				}
			}
		}

		// Optional execution list flow order (after)
		for (task in tasks) {
			var taskIndex:Int = allTasksIndexes.get(task);
			for (runAfter in task.task.__after) {
				for (it in tasks) {
					if (checkTaskWithDeps(it, task, runAfter)) {
						var relationIndex:Int = allTasksIndexes.get(it);
						executionOrderRelations[taskIndex][relationIndex] = 1;
					}
				}
			}
		}

		// Optional execution list flow order (before)
		for (task in tasks) {
			var taskIndex:Int = allTasksIndexes.get(task);
			for (runBefore in task.task.__before) {
				for (it in tasks) {
					if (checkTaskWithDeps(it, task, runBefore)) {
						var relationIndex:Int = allTasksIndexes.get(it);
						executionOrderRelations[relationIndex][taskIndex] = 1;
					}
				}
			}
		}

		var executionOrder:Array<TaskNode> = [];
		var usage:Array<Bool> = [for (i in 0...tasksLength) true];
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
			var cycledNodes:Array<String> = cycling.map(function(node:TaskNode):String {
				return node.toString();
			});
			throw 'There are cycling dependencies or run order between next tasks: `${cycledNodes.join(", ")}`';
		}

		return executionOrder;
	}

	static function addRangeUnique(array:Array<TaskNode>, range:Array<TaskNode>, ?checkArray:Array<TaskNode>):Array<TaskNode> {
		if (checkArray == null) checkArray = array;
		for (it in range) {
			if (checkArray.indexOf(it) < 0) {
				array.push(it);
			}
		}
		return array;
	}

	static function checkTaskWithDeps(node:TaskNode, withTask:TaskNode, dependencyName:String) {
		if (node.name == dependencyName) {
			if (withTask.module == node.module || withTask.module.getSubModules(false, true).indexOf(node.module) >= 0) {
				return true;
			}
		}
		return false;
	}
}
