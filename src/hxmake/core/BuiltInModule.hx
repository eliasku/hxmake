package hxmake.core;

import hxmake.tasks.InitTask;
import hxmake.tasks.InstallTask;
import hxmake.tasks.ListModules;
import hxmake.tasks.ListTask;

/**
	Built in module is module for default tasks,
	it's required to run default tasks in any folder,
	even where make modules are not defined
**/
@:root
class BuiltInModule extends Module {
	function new() {
		// TODO: better naming
		name = "__internal";
		task("_", new InstallTask());
		task("tasks", new ListTask());
		task("modules", new ListModules());
		task("init", new InitTask());
	}
}