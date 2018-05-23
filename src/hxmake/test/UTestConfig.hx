package hxmake.test;

typedef UTestConfig = {
	@:optional var debug:Bool;
	@:optional var targets:Array<String>;
	@:optional var libraries:Array<String>;
	// TODO:
	@:optional var defines:Array<String>;
}
