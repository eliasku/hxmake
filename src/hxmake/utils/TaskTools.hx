package hxmake.utils;

class TaskTools {

	public static function getDepth(task:Task):Int {
		var depth = 0;
		var current = task.parent;
		while (current != null) {
			++depth;
			current = current.parent;
		}
		return depth;
	}

#if hxmake_log
	public static function logStep<T:Task>(task:T, message:String) {
		var indent = StringTools.rpad("", "-", getDepth(task));
		var path = ${Type.getClassName(Type.getClass(task))};
		if(task.name != null) {
			path += '.${task.name}';
		}
		var moduleName = task.module != null ? task.module.name : null;
		moduleName = moduleName != null ? moduleName : ":";
		hxmake.cli.MakeLog.info('$indent~ $moduleName [$path] $message');
	}
#else

	@:pure
	inline public static function logStep(task:Task, message:String) {}
#end
}
