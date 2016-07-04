package hxmake;

class Task {

	public var pack:Array<String>;
	public var name:String;
	public var description:String = "";
	public var enabled:Bool = true;
	public var module(default, null):Module;
	public var chain(default, null):Array<Task> = [];
	public var parent(default, null):Task;

	var __after:Map<String, String> = new Map();
	var __before:Map<String, String> = new Map();
	var __finalized:Map<String, String> = new Map();
	var __depends:Map<String, String> = new Map();

	function _configure() {
		configure();
		for(chained in chain) {
			chained._configure();
		}
	}

	function _run() {
		run();
		for(chained in chain) {
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
		chain.push(task);
		task.parent = this;
		task.module = module;
		return task;
	}
}
