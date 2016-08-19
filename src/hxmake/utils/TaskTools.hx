package hxmake.utils;

class TaskTools {

	public static function getDepth(task:Task):Int {
		var depth = 0;
		var current = task.parent;
		while(current != null) {
			++depth;
			current = current.parent;
		}
		return depth;
	}

	public static function logStep<T:Task>(task:T, message:String) {
		var indent = StringTools.rpad("", "-", getDepth(task));
		var path = ${Type.getClassName(Type.getClass(task))};
		if(task.name != null) {
			path += '.${task.name}';
		}
		Sys.println('$indent~ [$path] $message');
	}
}
