package hxmake.core;

@:final
class ModuleConnectionData {

	public var parentPath(default, null):String;
	public var childPath(default, null):Array<String> = [];

	public function new(parentPath:String) {
		this.parentPath = parentPath;
	}
}
