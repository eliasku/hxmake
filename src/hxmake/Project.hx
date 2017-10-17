package hxmake;

import haxe.Timer;
import hxmake.cli.MakeLog;
import hxmake.core.CompiledProjectData;
import hxmake.core.ModuleGraph;
import hxmake.core.TaskQueue;
import hxmake.core.TaskQueueBuilder;

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

	var _moduleGraph:ModuleGraph;

	function new(buildArguments:Array<String>, isCompiler:Bool) {
		args = isCompiler ? buildArguments : buildArguments.concat(Sys.args());
		properties = parsePropertyMap(args);

		MakeLog.initialize(hasProperty("--silent"), hasProperty("--verbose"));

		if (isCompiler) {
			MakeLog.trace("[MakeProject] Compiler mode");
		}

		_moduleGraph = @:privateAccess new ModuleGraph(CompiledProjectData.getModules());
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

	public function hasProperty(name:String):Bool {
		return property(name) != null;
	}

	function run() {
		var startTime = Timer.stamp();

		printProperties();

		if (_moduleGraph.modules.length == 0) {
			MakeLog.error("Modules not found");
		}

		_moduleGraph.prepare(this);
		_moduleGraph.resolveHierarchy(CompiledProjectData.getConnectionsList());
		_moduleGraph.initialize();

		var taskQueue = new TaskQueue(TaskQueueBuilder.createNodeList(modules, parseTasks(args)));
		taskQueue.print();
		taskQueue.configure();
		taskQueue.run();

		_moduleGraph.finish();

		var totalTime = Std.int(100 * (Timer.stamp() - startTime)) / 100;
		MakeLog.info("Make time: " + totalTime + " sec.");
		Sys.exit(0);
	}

	function printProperties() {
		var first = true;
		for (name in properties.keys()) {
			if (first) {
				MakeLog.info("Running with properties:");
				first = false;
			}
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
//		MakeLog.info("search " + name);
		for (module in _moduleGraph.modules) {
			if (module.name == name) {
//				MakeLog.info("FOUND " + name);
				return module;
			}
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

	public static function parseTasks(args:Array<String>):Array<String> {
		var result:Array<String> = [];
		for (arg in args) {
			if (arg.charAt(0) != "-") {
				result.push(arg);
			}
		}
		return result;
	}
}