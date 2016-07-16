package hxmake;

import haxe.io.Path;
import haxe.Timer;

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

@:access(hxmake.Module)
@:access(hxmake.Task)
@:access(hxmake.Plugin)
class Project {

	public var args(default, null):Array<String> = [];
	public var modules(default, null):Array<Module> = [];
	public var roots(default, null):Array<Module> = [];

	function new(buildInArguments:Array<String>, isCompiler:Bool) {
		modules = _MODULES != null ? _MODULES : [];
		args = buildInArguments;
		if(!isCompiler) {
			args = args.concat(Sys.args());
		}
	}

	function run() {
		var startTime = Timer.stamp();

		for(module in modules) {
			module.project = this;
		}

		buildTree();
		findRoots();
		for(root in roots) {
			drawGraph(root);
		}

		for(module in modules) {
			module.__initialize();

			// apply default initialization
			// TODO: move to internal plugin
			if(module.config.makePath.indexOf("make") < 0) {
				module.config.makePath.push("make");
			}
			if(module.name != "hxmake" && module.config.devDependencies.get("hxmake") == null) {
				module.config.devDependencies.set("hxmake", "haxelib;global");
			}
		}

		var activeTasks:Array<String> = args.copy();
		var process:Bool = true;
		while(process) {
			process = false;
			for(module in modules) {
				var tasks:Map<String, Task> = module._tasks;
				for(tid in tasks.keys()) {
					var ct = tasks.get(tid);
					if(activeTasks.indexOf(tid) >= 0) {
						for(depTask in ct.__depends) {
							if(activeTasks.indexOf(depTask) < 0) {
								process = true;
								activeTasks.push(depTask);
							}
						}
					}
				}
			}
		}


		var taskList:Array<TaskInst> = [];
		var taskBeforeAfter:Map<String, String> = new Map();
		for(module in modules) {
			var tasks:Map<String, Task> = module._tasks;
			for(tid in tasks.keys()) {
				if(activeTasks.indexOf(tid) >= 0) {
					var t = tasks.get(tid);
					t._configure();
					taskList.push({
						name: tid,
						task: t
					});
					for(taskAfter in t.__before) {
						taskBeforeAfter.set(tid, taskAfter);
					}

					for(taskBefore in t.__after) {
						taskBeforeAfter.set(taskBefore, tid);
					}
				}
			}
		}

		taskList.sort(function(a:TaskInst, b:TaskInst) {
			var after = taskBeforeAfter.get(b.name);
			var prevAfter:String;
			while(after != null) {
				if(a.name == after) {
					return 1;
				}
				after = taskBeforeAfter.get(after);
			}
			return 0;
		});

		Sys.println("Task dependency order: ");
		for(ot in taskList) {
			Sys.println("\t" + ot.task.module.name + "." + ot.name);
		}

		for(ot in taskList) {
			if(ot.task.enabled) {
				ot.task._run();
			}
		}

		for(module in modules) {
			module.finish();
		}

		var totalTime = Std.int(100 * (Timer.stamp() - startTime)) / 100;
		Sys.println("Make time: " + totalTime + " sec.");
		Sys.exit(0);
	}

	function buildTree() {
		var connections:Map<String, Array<String>> = _MODULES_CONNECTIONS;
		if(connections == null) {
			return;
		}

		for(parentPath in connections.keys()) {
			for(parent in modules) {
				if(parent.path == parentPath) {
					for(childPath in connections.get(parentPath)) {
						for(child in modules) {
							if(child.path == childPath) {
								parent.addSubModule(child);
							}
						}
					}
				}
			}
		}
	}

	function findRoots() {
		for(module in modules) {
			if(module.parent == null) {
				roots.push(module);
			}
		}
	}

	function drawGraph(module:Module, pref:String = "", main:Bool = false) {
		var runDir = Path.directory(Sys.getCwd());
		var isRoot = module.parent == null;
		var left = isRoot ? "*-" : "--";
		var icon = "     ";
		if(main || runDir == module.path) {
			icon = main ? "[+]  " : "[^]  ";
			main = true;
		}

		Sys.println(icon + pref + left + " " + module.name + " @ " + module.path);
		var i = 0;
		for(child in module.children) {
			var sym = ++i == module.children.length ? "`" : "|";
			var indent = isRoot ? "" : "   ";
			drawGraph(child, pref + indent + sym, main);
		}
	}

	static var _MODULES:Array<Module>;
	static var _MODULES_CONNECTIONS:Map<String, Array<String>>;

	static function __registerModule(module:Module) {
		if(_MODULES == null) {
			_MODULES = [];
		}
		_MODULES.push(module);
	}

	public static function connect(parentModulePath:String, childModulePath:String) {
		if(parentModulePath == null || parentModulePath.length == 0) {
			return;
		}

		if(_MODULES_CONNECTIONS == null) {
			_MODULES_CONNECTIONS = new Map();
		}
		var children:Array<String> = _MODULES_CONNECTIONS.get(parentModulePath);
		if(children == null) {
			children = [];
			_MODULES_CONNECTIONS.set(parentModulePath, children);
		}
		children.push(childModulePath);
	}
}

private typedef TaskInst = {
	var task:Task;
	var name:String;
}