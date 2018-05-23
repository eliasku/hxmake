package hxmake.tests;

import haxe.io.Path;
import hxmake.cli.CL;
import hxmake.cli.MakeLog;
import hxmake.structure.PackageData;
import hxmake.structure.StructureBuilder;
import utest.Assert;

class BuildStructureTest {

	public function new() {}

	public function testSimple() {
		var cwd = CL.workingDir.current;
		MakeLog.warning(cwd);
		checkSimpleStructure(new StructureBuilder(Path.join([cwd, "testData/proj/"])));
		checkSimpleStructure(new StructureBuilder(Path.join([cwd, "testData/proj"])));
	}

	public function testLocal() {
		var cwd = CL.workingDir.current;
		checkSimpleStructure(new StructureBuilder(Path.join([cwd, "testData/proj/module1"])));
	}

	public function testDeep() {
		var cwd = CL.workingDir.current;
		checkSimpleStructure(new StructureBuilder(Path.join([cwd, "testData/proj/group/group_module1"])));
	}

	public function testExternal() {
		var cwd = CL.workingDir.current;
		checkSimpleStructure(new StructureBuilder(Path.join([cwd, "testData/proj/external/module1"])));
	}

	function checkSimpleStructure(n:StructureBuilder) {
		Assert.isTrue(n.root._children.length >= 1);
		var proj:PackageData = null;
		for (root in n.root._children) {
			MakeLog.info(root.name);
			if (root.name == "proj") {
				proj = root;
				break;
			}
		}
		Assert.equals(4, proj._children.length);
		Assert.equals("module1", proj._children[0].name);
		Assert.equals("module2", proj._children[1].name);
		Assert.equals("group_module1", proj._children[2].name);
		Assert.equals("external_module1", proj._children[3].name);
	}

//	public function testHxml() {
//		var cwd = CL.workingDir.current;
//		var n = new StructureBuilder(Path.join([cwd, "testData/proj/group/group_module1"]));
//		var hxml = new Hxml();
//		n.addToHxml(hxml);
//		for (cp in hxml.classPath) {
//			MakeLog.warning("-cp " + cp);
//		}
//		n.root.print();
//		Assert.pass();
//	}
}
