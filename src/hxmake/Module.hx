package hxmake;

@:autoBuild(hxmake.macr.ModuleMacro.build())
class Module {
	public var project(default, null):Project;
	public var root(get, never):Module;
	public var parent(default, null):Module;
	public var children(default, null):Array<Module> = [];

	// all nested modules
	public var subModules(get, never):Array<Module>;

	// this module + all nested modules
	public var allModules(get, never):Array<Module>;

	public var name(default, null):String;
	public var path(default, null):String;
	public var config(get, never):ModuleConfig;
	
	public var isMain(default, null):Bool = false;
	public var isActive(get, never):Bool;

	var _subModules:Array<Module>;
	var _data:Map<String, Dynamic> = ["config" => new ModuleConfig()];
	var _tasks:Map<String, Task> = new Map();
	var _plugins:Array<Plugin> = [];

	function __initialize() {
		// Constuctor will be moved here
	}

	function finish() {
		// Finalization phase
	}

	public function addSubModule(module:Module) {
		children.push(module);
		module.parent = this;
	}

	public function task(name:String, ?task:Task, ?type:Class<Task>):Task {
		if(task != null) {
			@:privateAccess task.module = this;
			_tasks.set(name, task);
			return task;
		}
		if(type != null) {
			throw "not implemented";
		}
		return _tasks.get(name);
	}

	inline public function getTask(name:String):Task {
		return _tasks.get(name);
	}

	public function set<T>(name:String, data:T):T {
		_data.set(name, data);
		return data;
	}

	public function get<T>(name:String, cls:Class<T>):Null<T> {
		return Std.instance(_data.get(name), cls);
	}

	function get_root():Module {
		var r = this;
		while(r.parent != null) {
			r = r.parent;
		}
		return r;
	}

	inline function get_config():ModuleConfig {
		return cast _data.get("config");
	}

	function get_allModules():Array<Module> {
		return [this].concat(subModules);
	}

	function get_subModules():Array<Module> {
		if(_subModules == null) {
			_subModules = children.copy();
			for(child in children) {
				_subModules = _subModules.concat(child.subModules);
			}
		}
		return _subModules;
	}

	function apply<T:Plugin>(plugin:Class<T>):T {
		var pluginInstance:T = cast Type.createInstance(plugin, []);
		@:privateAccess pluginInstance.apply(this);
		return pluginInstance;
	}

	public function update<T>(id:String, closure:T->Void):Module {
		var data:T = cast _data.get(id);
		if(data == null) {
			throw 'Data slot "$id" is not found';
		}
		closure(data);
		return this;
	}

	function get_isActive():Bool {
		return isMain || (parent != null && parent.isActive);
	}
}
