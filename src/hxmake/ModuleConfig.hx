package hxmake;

class ModuleConfig {

	public var description:String = "";
	public var version:String = "0.0.1";
	public var authors:Array<String> = [];
	public var classPath:Array<String> = [];
	public var testPath:Array<String> = [];
	public var makePath:Array<String> = [];
	public var dependencies:Map<String, String> = new Map();

	public function new() {}
}
