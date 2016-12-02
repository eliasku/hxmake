package hxmake.idea;

class IdeaLibraryInfo {

	public var name:String;
	public var classPath:Array<String>;

	public function new(name:String, classPath:Array<String>) {
		this.name = name;
		this.classPath = classPath;
	}
}
