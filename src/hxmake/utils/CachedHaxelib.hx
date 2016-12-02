package hxmake.utils;

class CachedHaxelib {

	static var _path:Map<String, String> = new Map();

	public static function classPath(lib:String, global:Bool):String {
		var key = lib + "|" + (global ? "g" : "l");
		if(_path.exists(key)) {
			return _path[key];
		}
		var path = Haxelib.classPath(lib, global);
		_path.set(key, path);
		return path;
	}

	public static function checkInstalled(library:String, global:Bool):Bool {
		return classPath(library, global) != null;
	}
}
