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

	var _taskGraph:TaskGraph;
	var _moduleGraph:ModuleGraph;

	function new(buildArguments:Array<String>, isCompiler:Bool) {
		MakeLog.initialize(buildArguments);

		if (isCompiler) {
			MakeLog.trace("[MakeProject] Compiler mode");
		}

		args = isCompiler ? buildArguments : buildArguments.concat(Sys.args());
		_moduleGraph = @:privateAccess new ModuleGraph();
		_taskGraph = @:privateAccess new TaskGraph(args, _moduleGraph.modules);
	}

	function run() {
		var startTime = Timer.stamp();

		_moduleGraph.prepare(this);
		_moduleGraph.resolveHierarchy();
		_moduleGraph.printHierarchies();
		_moduleGraph.initialize();

		_taskGraph.build();
		_taskGraph.printTasks();
		_taskGraph.run();

		_moduleGraph.finish();

		var totalTime = Std.int(100 * (Timer.stamp() - startTime)) / 100;
		MakeLog.info("Make time: " + totalTime + " sec.");
		Sys.exit(0);
	}

	inline function get_modules():Array<Module> {
		return _moduleGraph.modules;
	}

}