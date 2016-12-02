package hxmake.core;

@:final
class CompiledProjectData {

	static var MODULES:Array<Module>;
	static var CONNECTIONS:Map<String, ModuleConnectionData>;

	public static function registerModule(module:Module) {
		if (MODULES == null) {
			MODULES = [];
		}
		MODULES.push(module);
	}

	public static function createModuleConnection(parentModulePath:String, childModulePath:String) {
		if (parentModulePath == null || parentModulePath.length == 0) {
			return;
		}

		if (CONNECTIONS == null) {
			CONNECTIONS = new Map();
		}

		var data:ModuleConnectionData = CONNECTIONS.get(parentModulePath);
		if (data == null) {
			data = new ModuleConnectionData(parentModulePath);
			CONNECTIONS.set(parentModulePath, data);
		}
		data.childPath.push(childModulePath);
	}

	public static function getConnectionsList():Array<ModuleConnectionData> {
		var result = [];
		if (CONNECTIONS != null) {
			for (connection in CONNECTIONS) {
				result.push(connection);
			}
		}
		return result;
	}

	public static function getModules():Array<Module> {
		return MODULES != null ? MODULES : [];
	}
}
