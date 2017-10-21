package hxmake;

import haxe.io.Path;
import hxmake.cli.logging.Logger;
import hxmake.core.Arguments;

@:final
class Project {

	public var modules(default, null):Array<Module>;
	public var workingDir(default, null):String;
	public var logger(default, null):Logger;
	public var arguments(default, null):Arguments;

	@:access(hxmake.Module)
	function new(modules:Array<Module>, arguments:Arguments, workingDir:String, logger:Logger) {
		this.arguments = arguments;
		this.logger = logger;
		this.workingDir = Path.directory(workingDir);
		this.modules = modules;
		for (module in modules) {
			module.project = this;
		}
	}

	/**
	* Read property value from running Arguments
	* For example, `property("--build")` call:
	* 1) for arguments `--build=VALUE`, will return `VALUE`
	* 2) for argument `--build`, will return empty string
	* 3) if argument is not found, will return `null`
	*
	* @name - name of property (for example `--build`)
	* @returns - property value or Null of property is not provided
	**/
	public function property(name:String):Null<String> {
		return arguments.property(name);
	}

	public function hasProperty(name:String):Bool {
		return arguments.hasProperty(name);
	}

	public function findModuleByName(name:String):Module {
		for (module in modules) {
			if (module.name == name) {
				return module;
			}
		}
		return null;
	}
}