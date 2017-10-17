package hxmake.core;

@:final
@:access(hxmake.Task)
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
			addRangeUnique(tasks, findTaskDependencies(task));
		}
		return tasks;
	}

	function findTaskDependencies(taskNode:TaskNode):Array<TaskNode> {
		// find same task in module dependencies
		var dependedModules = taskNode.module.getSubModules(false, true);
		var nodes = _graph.getNodesForModules(dependedModules, taskNode.name);

		// find dependencies
		dependedModules.push(taskNode.module);
		for (depended in taskNode.task.__depends) {
			nodes = nodes.concat(requireDependedNodes(taskNode, depended, dependedModules));
		}

		var dependedNodes = [];
		for (node in nodes) {
			dependedNodes = dependedNodes.concat(findTaskDependencies(node));
		}
		return nodes.concat(dependedNodes);
	}

	function requireDependedNodes(target:TaskNode, depended:String, dependedModules:Array<Module>):Array<TaskNode> {
		var nodes = _graph.getNodesForModules(dependedModules, depended);
		if (nodes.length == 0) {
			throw 'Task with name `${depended}` not found in module `${target.module.name}`. Specified as dependency to `${target.name}`';
		}
		return nodes;
	}

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
					if (it.name == depended) {
						if (task.module == it.module || task.module.getSubModules(false, true).indexOf(it.module) >= 0) {
							dependedTasks.push(it);
						}
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
				var runAfterTask:TaskNode = null;
				for (it in tasks) {
					if (it.name == runAfter && task.module == it.module) {
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
					if (it.name == runBefore && task.module == it.module) {
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

	static function addRangeUnique(array:Array<TaskNode>, range:Array<TaskNode>) {
		for (it in range) {
			if (array.indexOf(it) < 0) {
				array.push(it);
			}
		}
	}
}
