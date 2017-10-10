package hxmake;

import haxe.Timer;
import hxmake.cli.MakeLog;
import hxmake.core.ModuleGraph;
import hxmake.core.TaskGraph;

/***

 1. COMPILE-TIME PHASE
 	-  Pluigns and modules are collected and code generated

 2. CONSTRUCTION PHASE
  	- Global make-project context is constructed
	- Set project context to each module
 	- Build modules tree
 	- Determine project's roots

 3. CONFIGURATION PHASE:
 	- Modules are initializing (plugins are applying as well)

 4. RESOLVING PHASE:
	- Task order resolving

 5. EXECUTION PHASE
	- Running

 6. FINALIZATION PHASE
	- Modules finish()

**/

class Project {

	public var args(default, null):Array<String>;
	public var modules(get, never):Array<Module>;
	public var properties(default, null):Map<String, String>;

	var _taskGraph:TaskGraph;
	var _moduleGraph:ModuleGraph;

	function new(buildArguments:Array<String>, isCompiler:Bool) {
		MakeLog.initialize(buildArguments);

		if (isCompiler) {
			MakeLog.trace("[MakeProject] Compiler mode");
		}

		args = isCompiler ? buildArguments : buildArguments.concat(Sys.args());
		properties = parsePropertyMap(args);

		_moduleGraph = @:privateAccess new ModuleGraph();
		_taskGraph = @:privateAccess new TaskGraph(args, _moduleGraph.modules);
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
		return properties.exists(name) ? properties.get(name) : null;
	}

	function run() {
		var startTime = Timer.stamp();

		printProperties();

		_moduleGraph.prepare(this);
		_moduleGraph.resolveHierarchy();
		_moduleGraph.printStructure();
		_moduleGraph.initialize();

		_taskGraph.build();
		_taskGraph.printTasks();
		_taskGraph.run();

		_moduleGraph.finish();

		var totalTime = Std.int(100 * (Timer.stamp() - startTime)) / 100;
		MakeLog.info("Make time: " + totalTime + " sec.");
		Sys.exit(0);
	}

	function printProperties() {
		MakeLog.info("Running with properties:");
		for (name in properties.keys()) {
			var value = property(name);
			var str = '  $name';
			if (value.length > 0) str += ' = $value';
			MakeLog.info(str);
		}
	}

	inline function get_modules():Array<Module> {
		return _moduleGraph.modules;
	}

	public function findModuleByName(name:String):Module {
		for (module in _moduleGraph.modules) {
			if (module.name == name) return module;
		}
		return null;
	}

	// TODO: move to utils
	static function parsePropertyMap(args:Array<String>):Map<String, String> {
		var props = new Map<String, String>();
		var re = ~/^(-[^=]+)[=]?(.*)?/;
		for (arg in args) {
			if (re.match(arg)) {
				props.set(re.matched(1), re.matched(2));
			}
		}
		return props;
	}
}