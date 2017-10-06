package hxmake;

using hxmake.utils.TaskTools;

class Task {

	public var pack:Array<String>;
	public var name:String;
	public var description:String = "";
	public var enabled:Bool = true;

	/**
	* `Module` associated with this Task
	**/
	public var module(default, null):Module;

	/**
	 * `Project` of associated module
	 * `null` if task is not linked to any module
	**/
	public var project(get, never):Project;

	public var chainBefore(default, null):Array<Task> = [];
	public var chainAfter(default, null):Array<Task> = [];

	public var parent(default, null):Task;

	var __after:Map<String, String> = new Map();
	var __before:Map<String, String> = new Map();
	var __finalized:Map<String, String> = new Map();
	var __depends:Map<String, String> = new Map();

	var _doFirst:Array<Task -> Void> = [];
	var _doLast:Array<Task -> Void> = [];

	function _configure() {
		this.logStep("Configuration BEGIN");
		configure();
		this.logStep("Sub-tasks configuration (BEFORE)");
		for (chained in chainBefore) {
			chained._configure();
		}
		this.logStep("Sub-tasks configuration (AFTER)");
		for (chained in chainAfter) {
			chained._configure();
		}
		this.logStep("Configuration END");
	}

	function _run() {
		this.logStep("Run BEGIN");
		this.logStep("Run BEFORE tasks");

		for (chained in chainBefore) {
			chained._run();
		}
		for (cb in _doFirst) {
			cb(this);
		}
		this.logStep("Running");
		run();

		this.logStep("Run AFTER tasks");
		for (cb in _doLast) {
			cb(this);
		}
		for (chained in chainAfter) {
			chained._run();
		}
		this.logStep("Run END");
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
		if (parent != null) {
			throw 'Sub-task $name of task ${parent.name} failed: \n$description';
		}
		else {
			throw 'Task $name failed: \n$description';
		}
	}

	public function doFirst(func:Task -> Void):Task {
		_doFirst.push(func);
		return this;
	}

	public function doLast(func:Task -> Void):Task {
		_doLast.push(func);
		return this;
	}

	function get_project():Project {
		return module != null ? module.project : null;
	}
}
