package hxmake.idea;

typedef IdeaTemplateContext = {
	var moduleName:String;
	var moduleDependencies:Array<String>;
	var moduleLibraries:Array<IdeaLibraryInfo>;
	var moduleDir:String;

	var sourceDirs:Array<String>;
	var testDirs:Array<String>;
	var testResDirs:Array<String>;
	var resDirs:Array<String>;

	var flexSdkName:String;
	var haxeSdkName:String;
	var buildConfig:Int;
	var projectPath:String;
	var projectTarget:String;
	var skipCompilation:Bool;
}