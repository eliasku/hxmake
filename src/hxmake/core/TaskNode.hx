package hxmake.core;

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
}
