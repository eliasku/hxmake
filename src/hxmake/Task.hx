package hxmake;

class Task {

	public var name:String;
	public var description:String = "";
	public var enabled:Bool = true;

	/**
	* `Module` associated with this task node
	**/
	public var module(get, never):Module;

	/**
	 * `Project` of associated module
	 * `null` if task is not linked to any module
	**/
	public var project(get, never):Project;

	public var parent(default, null):Task;

	/** Task attached directly to this task **/
	var _module:Module;

	/** Children before run BEFORE parent **/
	var _childrenBefore:Array<Task> = [];

	/** Children before run AFTER parent **/
	var _childrenAfter:Array<Task> = [];

	var __after:Map<String, String> = new Map();
	var __before:Map<String, String> = new Map();
	var __finalized:Map<String, String> = new Map();
	var __depends:Map<String, String> = new Map();

	var _doFirst = new Array<Task -> Void>();
	var _doLast = new Array<Task -> Void>();

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

	public function toString() {
		return 'Task $name ($description)';
	}

	public function configure() {}

	public function run() {}

	public function prepend(task:Task):Task {
		return attachChild(task, _childrenBefore, true);
	}

	public function then(task:Task):Task {
		return attachChild(task, _childrenAfter, false);
	}

	public function doFirst(func:Task -> Void):Task {
		_doFirst.insert(0, func);
		return this;
	}

	public function doLast(func:Task -> Void):Task {
		_doLast.push(func);
		return this;
	}

	function fail(description:String = "") {
		if (parent != null) {
			throw 'Sub-task $name of task ${parent.name} failed: \n$description';
		}
		else {
			throw 'Task $name failed: \n$description';
		}
	}

	function attachChild(task:Task, array:Array<Task>, prepend:Bool):Task {
		if (task.parent != null) project.logger.error("Task is a child already (TODO: info)");
		task.parent = this;

		if (_childrenBefore.indexOf(task) >= 0 || _childrenAfter.indexOf(task) >= 0) project.logger.error("Task is registered as child already (TODO: info)");
		if (prepend) array.unshift(task);
		else array.push(task);

		return this;
	}

	function get_project():Project {
		var m = this.module;
		return m != null ? m.project : null;
	}

	function get_module():Module {
		return _module != null ? _module : (parent != null ? parent.module : null);
	}

	public static function empty(name:String = null, description = ""):Task {
		var task = new EmptyTask();
		task.name = name;
		task.description = description;
		return task;
	}

	public static function func(fn:Void -> Void, name:String = null, description = ""):Task {
		return empty(name, description).doLast(function(_) {
			fn();
		});
	}
}


private class EmptyTask extends Task {
	function new() {}

	override public function run() {}
}