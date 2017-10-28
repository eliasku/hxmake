package hxmake.tests;

import hxmake.cli.MakeLog;
import hxmake.core.TaskRunner;
import utest.Assert;

class TaskRunnerTest {

	public function new() {}

	public function testTaskRunner() {
		var logger = MakeLog.logger;
		var runner = new TaskRunner(logger);

		var result = [];
		var root_task = Task.empty("root_task");
		root_task.prepend(Task.func(function() {
			result.push("pre");
		}, "pre"))
		.prepend(Task.func(function() {
			result.push("pre-pre");
		}, "pre-pre"))
		.then(Task.func(function() {
			result.push("post");
		}, "post"));
		root_task.then(Task.func(function() {
			result.push("post-post");
		}, "post-post"));

		root_task.doFirst(function(_) {
			logger.trace("CALL first");
			result.push("first");
		});
		root_task.doFirst(function(_) {
			logger.trace("CALL before first");
			result.push("before first");
		});

		root_task.doLast(function(_) {
			result.push("last");
			logger.trace("CALL last");
		});
		root_task.doLast(function(_) {
			result.push("after last");
			logger.trace("CALL after last");
		});

		runner.run(root_task);
		Assert.same(["pre-pre", "pre", "before first", "first", "last", "after last", "post", "post-post"], result);
	}
}
