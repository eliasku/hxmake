package hxmake.cli;

class WorkingDirectory {

	var _stack:Array<String>;

	public var current(get, set):String;

	public function new() {
		_stack = [Sys.getCwd()];
	}

	public function with<T>(path:String, func:Void->T):T {
		push(path);
		var result = func();
		pop();
		return result;
	}

	public function push(path:String):String {
		var prev = current;
		if (path == null) {
			path = prev;
		}
		_stack.push(path);
		current = path;
		return prev;
	}

	public function pop():String {
		var prev:String = _stack.pop();
		Sys.setCwd(current);
		return prev;
	}

	inline function set_current(value:String) {
		_stack[_stack.length - 1] = value;
		Sys.setCwd(value);
		return value;
	}

	inline function get_current():String {
		return _stack[_stack.length - 1];
	}

}
