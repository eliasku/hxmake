package hxmake.tests;

import hxmake.core.CompiledProjectData;
import hxmake.tests.utils.StubModule;
import utest.Assert;

class ModuleConnectionTest {

	public function new() {}

	public function setup() {}

	@:access(hxmake.core.CompiledProjectData)
	public function testConnections() {
		var data = new CompiledProjectData();
		var root = StubModule.create("~/root", "root");
		var rootModulesM1 = StubModule.create("~/root/modules/m1", "m1");
		var rootM1 = StubModule.create("~/root/m1", "m1");

		data.addModule(root);
		data.addModule(rootModulesM1);
		data.addModule(rootM1);

		data.connect(root.path, rootModulesM1.path);
		data.connect(root.path, rootM1.path);

		var modules = data.build();

		Assert.equals(2, root.children.length);

		Assert.contains(rootModulesM1, root.children);
		Assert.isTrue(root == rootModulesM1.parent);
		Assert.isTrue(root == rootModulesM1.root);

		Assert.contains(rootM1, root.children);
		Assert.isTrue(root == rootM1.parent);
		Assert.isTrue(root == rootM1.root);
	}

	public function teardown() {}
}
