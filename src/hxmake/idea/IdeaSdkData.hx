package hxmake.idea;

class IdeaSdkData {
	public var type(default, null):String;
	public var name(default, null):String;
	public var version(default, null):String;
	public var path(default, null):String;

	public function new(type:String, name:String, version:String, path:String) {
		this.type    = type;
		this.name    = name;
		this.version = version;
		this.path    = path;
	}

	public function is(value:String):Bool {
		return type.indexOf(value) == 0;
	}
}
