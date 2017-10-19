package hxmake.tests;

import hxmake.cli.logging.Logger;
import hxmake.core.Arguments;
import hxmake.core.ProjectRunner;
import utest.Assert;

@:access(hxmake)
class RunEmptyProjectTest {

	var _project:Project;

	public function new() {}

	public function setup() {
		// no modules
		var modules = [];
		// empty arguments
		var args = new Arguments([]);
		// mute logs
		var logger = new Logger(0);
		// working dir
		var cwd = "";

		_project = new Project(modules, args, cwd, logger);
	}

	public function testProject() {
		ProjectRunner.runProject(_project);
		Assert.pass("Project created and run passed");
	}

	public function teardown() {}
}