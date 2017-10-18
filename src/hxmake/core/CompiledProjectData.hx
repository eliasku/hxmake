package hxmake.core;

@:final
class CompiledProjectData {

	public var isCompiler(default, null):Bool = false;
	public var buildArguments(default, null):Array<String> = [];
	public var modules(default, null):Array<Module> = [];

	var _connectionsMap:Map<String, ModuleConnectionData> = new Map();

	function new() {}

	public function getConnections():Array<ModuleConnectionData> {
		return Lambda.array(_connectionsMap);
	}

	public function connect(parentModulePath:String, childModulePath:String) {
		if (parentModulePath == null || parentModulePath.length == 0) {
			return;
		}

		var data:ModuleConnectionData = _connectionsMap.get(parentModulePath);
		if (data == null) {
			data = new ModuleConnectionData(parentModulePath);
			_connectionsMap.set(parentModulePath, data);
		}
		data.childPath.push(childModulePath);
	}

	/**
	* Static methods for access CURRENT context provided by project compilation
	* **/

	@:isVar public static var CURRENT(get, null):CompiledProjectData;

	public static function initCurrent(buildArguments:Array<String>, isCompiler:Bool) {
		CURRENT.buildArguments = buildArguments;
		CURRENT.isCompiler = isCompiler;
	}

	public static function registerModule(module:Module) {
		CURRENT.modules.push(module);
	}

	public static function createModuleConnection(parentModulePath:String, childModulePath:String) {
		CURRENT.connect(parentModulePath, childModulePath);
	}

	static function get_CURRENT():CompiledProjectData {
		if (CURRENT == null) {
			CURRENT = new CompiledProjectData();
		}
		return CURRENT;
	}
}
