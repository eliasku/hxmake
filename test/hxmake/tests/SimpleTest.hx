package hxmake.tests;

import hxmake.core.CompiledProjectData;
import utest.Assert;

@:access(hxmake)
class SimpleTest {

	var _project:Project;

	public function new() {}

	public function setup() {
		var input = new CompiledProjectData();
		_project = new Project(input);
	}

	public function testLog() {
		_project.run();
		Assert.pass("Project created and run passed");
	}

	public function teardown() {

	}
}