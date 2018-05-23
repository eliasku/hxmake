package hxmake.idea;

typedef IdeaData = {

	@:optional var hideIml:Bool;

	// group for idea module 'grouping'
	@:optional var group:String;

	// iml path
	//public var imlPath:String;

	// lime project file,
	// TODO: "" - search project.lime/xml,
	// TODO: "path to dir or project.lime"
	@:optional var lime:String;

	// path to hxml
	@:optional var hxml:String;

	@:optional var run:Array<IdeaRunData>;

	@:optional var testResources:Array<String>;
	@:optional var resources:Array<String>;
}
