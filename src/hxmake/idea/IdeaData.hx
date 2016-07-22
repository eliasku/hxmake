package hxmake.idea;

class IdeaData {

	// group for idea module 'grouping'
	public var group:String;

	// lime project file,
	// TODO: "" - search project.lime/xml,
	// TODO: "path to dir or project.lime"
	public var lime:String;

	// path to hxml
	public var hxml:String;

	public var run(default, null):Array<IdeaRunData> = [];

	public function new() {}

	public function addHaxeRun(file:String) {
		var r = new IdeaRunData();
		r.file = file;
		r.type = "haxe";
		run.push(r);
	}
}
