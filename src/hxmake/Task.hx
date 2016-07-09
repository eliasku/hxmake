package hxmake;

class Task {

	public var pack:Array<String>;
	public var name:String;
	public var description:String = "";
	public var enabled:Bool = true;
	public var module(default, null):Module;

	public var chainBefore(default, null):Array<Task> = [];
	public var chainAfter(default, null):Array<Task> = [];

	public var parent(default, null):Task;

	var __after:Map<String, String> = new Map();
	var __before:Map<String, String> = new Map();
	var __finalized:Map<String, String> = new Map();
	var __depends:Map<String, String> = new Map();

	function _configure() {
		configure();
		for(chained in chainBefore) {
			chained._configure();
		}
		for(chained in chainAfter) {
			chained._configure();
		}
	}

	function _run() {
		for(chained in chainBefore) {
			chained._run();
		}
		run();
		for(chained in chainAfter) {
			chained._run();
		}
	}

	public function runAfter(task:String):Task {
		__after.set(task, task);
		return this;
	}

	public function runBefore(task:String):Task {
		__before.set(task, task);
		return this;
	}

	public function finalizedBy(task:String):Task {
		__finalized.set(task, task);
		return this;
	}

	public function dependsOn(task:String):Task {
		__depends.set(task, task);
		runAfter(task);
		return this;
	}

	public function configure() {}
	public function run() {}

	public function then<T:Task>(task:T):T {
		chainAfter.push(task);
		task.parent = this;
		task.module = module;
		return task;
	}

	public function prepend<T:Task>(task:T):T {
		chainBefore.push(task);
		task.parent = this;
		task.module = module;
		return task;
	}

	function fail(description:String = "") {
		if(parent != null) {
			throw 'Sub-task $name of task ${parent.name} failed: \n$description';
		}
		else {
			throw 'Task $name failed: \n$description';
		}
	}
}
