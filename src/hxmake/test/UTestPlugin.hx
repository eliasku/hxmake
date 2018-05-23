package hxmake.test;

class UTestPlugin {
	public static function apply(module:Module) {
		var test = new TestTask();
		var config:UTestConfig = module.getExtConfig("utest");
		if (config.debug != null) {
			test.debug = config.debug;
		}
		if (config.targets != null) {
			test.targets = config.targets;
		}
		if (config.libraries != null) {
			test.libraries = config.libraries;
		}
		module.task("test", test);
	}
}
