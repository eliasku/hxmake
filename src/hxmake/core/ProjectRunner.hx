package hxmake.core;

import hxmake.cli.CL;
import hxmake.utils.Haxe;
import hxmake.utils.Hxml;
import hxmake.cli.FileUtil;
import haxe.io.Path;
import haxe.Timer;
import hxmake.cli.logging.Logger;
import hxmake.haxelib.HaxelibConfig;
import hxmake.idea.IdeaData;
import hxmake.json.JsonSchemaBuilder;
import hxmake.structure.PackageData;
import hxmake.structure.StructureBuilder;
import hxmake.test.UTestConfig;
import hxmake.utils.Haxelib;

typedef MakeConfigSchema = {
> PackageData,
	@:optional var idea:IdeaData;
	@:optional var config:ModuleConfig;
	@:optional var haxelib:HaxelibConfig;
	@:optional var utest:UTestConfig;
};

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
	static function runFromInitMacro(args:Array<String>, workingDir:String, sysArgs:Array<String>, logger:Logger) {
		var totalTime = measure(function() {
			var arguments = new Arguments(args.concat(sysArgs));
			var modules = scan(workingDir);

			logger.setupFilter(
				arguments.hasProperty(MakeArgument.SILENT),
				arguments.hasProperty(MakeArgument.VERBOSE)
			);

			// print input information
			var printer = new Printer(logger);
			printer.printArguments(arguments);
			printer.printModules(modules);

			var schema = JsonSchemaBuilder.generate(MakeConfigSchema);
			var libPath = Haxelib.libPath("hxmake");
			var schemaString = haxe.Json.stringify(schema, "  ");
			schemaString = StringTools.replace(schemaString, "__dollar__", "$");
			sys.io.File.saveContent(Path.join([libPath, "hxmake.schema.json"]), schemaString);
			sys.io.File.saveContent(Path.join([modules[0].path, "hxmake.schema.json"]), schemaString);

			test(modules);

			runProject(new Project(modules, arguments, workingDir, logger));
		});
		logger.info('Make time: $totalTime sec.');
		Sys.exit(0);
	}

	static function test(modules:Array<Module>) {
		for(module in modules) {
			var p = Path.join([module.path, "import.hx"]);
			if(FileUtil.fileExists(p)) {
				CL.workingDir.with(module.path, function() {
					Haxe.exec(["-cp", ".", "-main", "Main", "-js", "out.js"]);
				});
			}
		}
	}

	@:access(hxmake.core.BuiltInModule)
	static public function scan(path:String) {
		var sb = new StructureBuilder(path);
		var modules = [];
		visitStructure(sb.root, modules);
		var bim = new BuiltInModule();
		bim.path = path;
		bim.packageData = StructureBuilder.initPackage(path, {});
		modules.push(bim);
		return modules;
	}

	@:access(hxmake.Module)
	static function visitStructure(pack:PackageData, modules:Array<Module>):Module {
		var module = createModule(pack);
		if (module != null) {
			modules.push(module);
		}
		if (pack._children != null) {
			for (childNode in pack._children) {
				var child = visitStructure(childNode, modules);
				if (child != null && module != null) {
					module._children.push(child);
					child.parent = module;
				}
			}
		}
		return module;
	}

	@:access(hxmake.Module)
	static function createModule(pack:PackageData):Module {
		if (pack.name != null) {
			var module = new Module();
			module.path = pack.path;
			module.name = pack.name;
			module.packageData = pack;
			return module;
		}
		return null;
	}

	static function runProject(project:Project) {
		var modules = project.modules;
		var moduleGraph = new ModuleGraph(modules);
		moduleGraph.initialize();
		moduleGraph.configure();

		var tasks = TaskQueueBuilder.createNodeList(modules, project.arguments.tasks);
		new Printer(project.logger).printTaskOrder(tasks);

		var taskQueue = new TaskQueue(tasks, project.logger);
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
