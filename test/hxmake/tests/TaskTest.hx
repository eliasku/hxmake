package hxmake.tests;

import hxmake.cli.MakeLog;
import hxmake.core.Arguments;
import hxmake.tests.utils.StubModule;
import utest.Assert;

class TaskTest {

	public function new() {}

	@:access(hxmake.Project)
	public function testTask() {
		var empty_task_1 = Task.empty("task-1", "description");
		Assert.equals("task-1", empty_task_1.name);
		Assert.equals("description", empty_task_1.description);

		var module = StubModule.create("", "module");
		var project = new Project([module], new Arguments([]), "", MakeLog.logger);
		module.task("t", empty_task_1);

		Assert.equals(project, empty_task_1.project);
		Assert.equals(module, empty_task_1.module);

		var fn_task_1 = Task.func(function() {});
		empty_task_1.prepend(fn_task_1);
		Assert.equals(empty_task_1, fn_task_1.parent);
		Assert.equals(project, fn_task_1.project);
		Assert.equals(module, fn_task_1.module);

		var fn_task_2 = Task.func(function() {});
		empty_task_1.then(fn_task_2);
		Assert.equals(empty_task_1, fn_task_2.parent);
		Assert.equals(project, fn_task_2.project);
		Assert.equals(module, fn_task_2.module);
	}
}


