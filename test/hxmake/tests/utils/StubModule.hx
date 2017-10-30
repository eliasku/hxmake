package hxmake.tests.utils;

class StubModule extends Module {

	public function new() {}

	@:access(hxmake.Module)
	public static function create(path:String, name:String):Module {
		var m = new StubModule();
		m.path = path;
		m.name = name;
		return m;
	}
}
