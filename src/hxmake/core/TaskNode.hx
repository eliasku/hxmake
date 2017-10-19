package hxmake.core;

/**
	Node for task graph
**/
class TaskNode {
	public var name(default, null):String;
	public var task(default, null):Task;
	public var module(get, never):Module;

	public function new(name:String, task:Task) {
		this.name = name;
		this.task = task;
	}

	function get_module():Module {
		return task.module;
	}

	public function toString() {
		return module.name + "::" + name;
	}

	public function equals(other:TaskNode) {
		return name == other.name && module == other.module;
	}
}
