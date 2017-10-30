package hxmake.core;

import hxmake.cli.logging.Logger;

class TaskRunner {

	public var logger(default, null):Logger;

	public function new(logger:Logger) {
		this.logger = logger;
	}

	@:access(hxmake.Task)
	public function configure(task:Task) {
		logStep(task, "Configuration BEGIN");

		task.configure();

		logStep(task, "Sub-tasks configuration (BEFORE)");
		for (child in task._childrenBefore) {
			configure(child);
		}
		logStep(task, "Sub-tasks configuration (AFTER)");
		for (child in task._childrenAfter) {
			configure(child);
		}
		logStep(task, "Configuration END");
	}

	@:access(hxmake.Task)
	public function run(task:Task) {
		if (!task.enabled) {
			logStep(task, "Task disabled");
		}

		logStep(task, "Run BEGIN");
		logStep(task, "Run BEFORE tasks");

		for (child in task._childrenBefore) {
			run(child);
		}

		for (fn in task._doFirst) {
			fn(task);
		}
		logStep(task, "Running");

		task.run();

		logStep(task, "Run AFTER tasks");
		for (fn in task._doLast) {
			fn(task);
		}

		for (child in task._childrenAfter) {
			run(child);
		}
		logStep(task, "Run END");
	}

//	function getTaskRunnner(task:Task):TaskRunner {
//		return task.runner != null ? task.runner : this;
//	}

	function logStep(task:Task, message:String) {
		var indent = StringTools.rpad("", "-", getDepth(task));
		var path = ${Type.getClassName(Type.getClass(task))};
		if (task.name != null) {
			path += '.${task.name}';
		}
		var moduleName = task.module != null ? task.module.name : null;
		moduleName = moduleName != null ? moduleName : ":";
		logger.debug('$indent~ $moduleName [$path] $message');
	}

	static function getDepth(task:Task):Int {
		var depth = 0;
		var current = task.parent;
		while (current != null) {
			++depth;
			current = current.parent;
		}
		return depth;
	}
}
