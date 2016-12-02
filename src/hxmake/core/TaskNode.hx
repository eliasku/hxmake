package hxmake.core;

class TaskNode {

	public var name(default, null):String;
	public var task(default, null):Task;

	public function new(name:String, task:Task) {
		this.name = name;
		this.task = task;
	}
}
