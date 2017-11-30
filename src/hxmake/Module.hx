package hxmake;

import hxmake.cli.FileUtil;

@:autoBuild(hxmake.macr.ModuleMacro.build())
class Module {
	/**
		Shared "project" context between modules.
	**/
	public var project(default, null):Project;

	/**
		Root module
	**/
	public var root(get, never):Module;
	public var parent(default, null):Module;
	public var children(get, never):Array<Module>;

	public var name(default, null):String;

	/**
		Absolute path to Module folder
	**/
	public var path(default, null):String;
	public var config(get, never):ModuleConfig;

	/**
		Module is "main" (or current).
		That means that `hxmake` running in the directory of this module.
	**/
	public var isMain(get, never):Bool;

	/**
		Active means that module is "main" or have "main" ancestor.
	**/
	public var isActive(get, never):Bool;

	var _children:Array<Module> = [];
	var _tasks:Map<String, Task> = new Map();
	var _plugins:Array<Plugin> = [];
	var _data:Map<String, Dynamic> = ["config" => new ModuleConfig()];

	function __initialize() {
		// Constuctor will be moved here
	}

	function configure() {
		// Configuration phase
	}

	function finish() {
		// Finalization phase
	}

	@:access(hxmake.Task)
	public function task(name:String, ?task:Task, ?type:Class<Task>):Task {
		if (task != null) {
			task._module = this;
			_tasks.set(name, task);
			return task;
		}
		if (type != null) {
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
		while (r.parent != null) {
			r = r.parent;
		}
		return r;
	}

	inline function get_config():ModuleConfig {
		return cast _data.get("config");
	}

	// TODO: bool arguments to int-flags?
	public function getSubModules(includeSelf:Bool = false, includeDependecies:Bool = false):Array<Module> {
		var result = [];

		if (includeSelf) {
			result.push(this);
		}

		for (child in children) {
			var childSubModules = child.getSubModules(true, false);
			for (childSubModule in childSubModules) {
				result.push(childSubModule);
			}
		}

		if (includeDependecies) {
			var dependencyMap = config.getAllDependencies();
			for (dependency in dependencyMap.keys()) {
				var module = project.findModuleByName(dependency);
				if (module != null && result.indexOf(module) < 0) {
					result.push(module);
				}
			}
		}

		return result;
	}

	function apply<T:Plugin>(plugin:Class<T>):T {
		var pluginInstance:T = cast Type.createInstance(plugin, []);
		@:privateAccess pluginInstance.apply(this);
		return pluginInstance;
	}

	public function update<T>(id:String, closure:T -> Void):Module {
		var data:T = cast _data.get(id);
		if (data == null) {
			throw 'Data slot "$id" is not found';
		}
		closure(data);
		return this;
	}

	function get_children():Array<Module> {
		return _children.copy();
	}

	function get_isActive():Bool {
		return isMain || (parent != null && parent.isActive);
	}

	function get_isMain():Bool {
		return FileUtil.pathEquals(path, project.workingDir);
	}
}
