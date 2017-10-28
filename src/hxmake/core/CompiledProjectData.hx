package hxmake.core;

/**
	Storage for data, which collected during compilation, or manually provided for Project
**/
@:final
class CompiledProjectData {

	var _modules:Array<Module> = [];
	var _connectionsMap:Map<String, ModuleConnectionData> = new Map();

	function new() {}

	public function addModule(module:Module) {
		_modules.push(module);
	}

	public function build():Array<Module> {
		resolveHierarchy(_modules, _connectionsMap);
		return _modules;
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

	static function resolveHierarchy(modules:Array<Module>, connections:Iterable<ModuleConnectionData>) {
		for (connection in connections) {
			for (parent in modules) {
				if (parent.path == connection.parentPath) {
					for (childPath in connection.childPath) {
						for (child in modules) {
							if (child.path == childPath) {
								appendChildModule(parent, child);
							}
						}
					}
				}
			}
		}
	}

	@:access(hxmake.Module)
	static function appendChildModule(parent:Module, child:Module) {
		parent._children.push(child);
		child.parent = parent;
	}

	/**
	* Static methods for access CURRENT context provided by project compilation
	* **/

	@:isVar public static var CURRENT(get, null):CompiledProjectData;

	static function get_CURRENT():CompiledProjectData {
		if (CURRENT == null) {
			CURRENT = new CompiledProjectData();
		}
		return CURRENT;
	}
}
