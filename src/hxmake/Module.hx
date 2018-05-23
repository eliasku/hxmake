package hxmake;

import haxe.DynamicAccess;
import hxmake.cli.FileUtil;
import hxmake.structure.PackageData;

class Module {
	/**
		Shared "project" context between modules.
	**/
	public var project(default, null):Project;

	public var packageData(default, null):PackageData;

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

	function new() {}

	function initialize() {
		// initialize phase
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

	public function getExtConfig<T>(name:String):T {
		return (cast packageData:DynamicAccess<T>).get(name);
	}

	public function requireOptionalExtConfig<T>(name:String):T {
		var ext = getExtConfig(name);
		if (ext == null) {
			ext = {};
			(cast packageData:DynamicAccess<Dynamic>).set(name, ext);
		}
		return cast ext;
	}

	function get_root():Module {
		var r = this;
		while (r.parent != null) {
			r = r.parent;
		}
		return r;
	}

	inline function get_config():ModuleConfig {
		return getExtConfig("config");
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
			var dependencyMap = getAllDependenciesFromConfig(config);
			for (dependency in dependencyMap.keys()) {
				var module = project.findModuleByName(dependency);
				if (module != null && result.indexOf(module) < 0) {
					result.push(module);
				}
			}
		}

		return result;
	}

	public static function getAllDependenciesFromConfig(config:ModuleConfig):Map<String, String> {
		var deps = new Map<String, String>();
		if (config.devDependencies != null) {
			for (name in config.devDependencies.keys()) {
				deps[name] = config.devDependencies[name];
			}
		}
		if (config.dependencies != null) {
			for (name in config.dependencies.keys()) {
				deps[name] = config.dependencies[name];
			}
		}
		return deps;
	}

	function apply<T:Plugin>(plugin:Class<T>):T {
		var pluginInstance:T = cast Type.createInstance(plugin, []);
		@:privateAccess pluginInstance.apply(this);
		return pluginInstance;
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
