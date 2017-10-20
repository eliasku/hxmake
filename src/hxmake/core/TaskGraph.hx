package hxmake.core;

import hxmake.utils.ArrayTools;
import hxmake.utils.MapTools;
using hxmake.utils.MapTools;

/**
	Internal structure transforms modules and tasks to unique TaskNode lookups for searching,
	and provide utility functions.
**/

@:final
class TaskGraph {

	var _byName:Map<String, Array<TaskNode>> = new Map();
	var _byModule:Map<String, Array<TaskNode>> = new Map();

	@:access(hxmake.Module)
	public function new(modules:Array<Module>) {
		for (module in modules) {
			var tasks = module._tasks;
			for (name in tasks.keys()) {
				var node = new TaskNode(name, tasks.get(name));
				MapTools.pushToValueArray(_byName, name, node);
				MapTools.pushToValueArray(_byModule, module.name, node);
			}
		}
	}

	public function getNodes(name:String):Array<TaskNode> {
		var nodes = _byName.get(name);
		return nodes != null ? nodes : [];
	}

	public function getNodesInModule(module:Module):Array<TaskNode> {
		var nodes = _byModule.get(module.name);
		return nodes != null ? nodes : [];
	}

	public function requireNodes(task:String):Array<TaskNode> {
		var nodes = getNodes(task);
		if (nodes.length == 0) {
			throw 'Task `${task}` not found';
		}
		return nodes;
	}

	public function getNodesForModules(modules:Array<Module>, task:String):Array<TaskNode> {
		var nodes = [];
		for (module in modules) {
			var moduleNodes = getNodesInModule(module);
			for (moduleNode in moduleNodes) {
				if (moduleNode.name == task) {
					nodes.push(moduleNode);
				}
			}
		}
		return nodes;
	}

	public function requireTasks(names:Array<String>):Array<TaskNode> {
		var result:Array<TaskNode> = [];
		for (name in names) {
			ArrayTools.pushRange(result, requireNodes(name));
		}
		return result;
	}
}