package hxmake;

class ModuleConfig {

	public var description:String = "";
	public var version:String = "0.0.1";
	public var authors:Array<String> = [];
	public var classPath:Array<String> = [];
	public var testPath:Array<String> = [];
	public var makePath:Array<String> = [];
	public var dependencies:Map<String, String> = new Map();
	public var devDependencies:Map<String, String> = new Map();

	public function new() {}

	public function getAllDependencies():Map<String, String> {
		var deps = new Map<String, String>();
		for(dev in devDependencies.keys()) {
			deps[dev] = devDependencies[dev];
		}
		for(dev in dependencies.keys()) {
			deps[dev] = dependencies[dev];
		}
		return deps;
	}
}
