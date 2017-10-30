package hxmake.core;

import haxe.Timer;
import hxmake.cli.logging.Logger;

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

@:final
class ProjectRunner {
	@:access(hxmake)
	static function runFromInitMacro(args:Array<String>, isCompiler:Bool, modules:Array<Module>, workingDir:String, sysArgs:Array<String>, logger:Logger) {
		var totalTime = measure(function() {
			var arguments = new Arguments(isCompiler ? args : args.concat(sysArgs));

			logger.setupFilter(
				arguments.hasProperty(MakeArgument.SILENT),
				arguments.hasProperty(MakeArgument.VERBOSE)
			);

			// print input information
			var printer = new Printer(logger);
			printer.printCompilerMode(isCompiler);
			printer.printArguments(arguments);
			printer.printModules(modules);

			runProject(new Project(modules, arguments, workingDir, logger));
		});
		logger.info('Make time: $totalTime sec.');
		Sys.exit(0);
	}

	static function runProject(project:Project) {
		var modules = project.modules;
		var moduleGraph = new ModuleGraph(modules);
		moduleGraph.initialize();
		moduleGraph.configure();

		var tasks = TaskQueueBuilder.createNodeList(modules, project.arguments.tasks);
		new Printer(project.logger).printTaskOrder(tasks);

		var taskQueue = new TaskQueue(tasks);
		taskQueue.configure();
		taskQueue.run();

		moduleGraph.finish();
	}

	static function measure(fn:Void -> Void):Float {
		var time = Timer.stamp();

		fn();

		return Std.int(100 * (Timer.stamp() - time)) / 100;
	}
}
