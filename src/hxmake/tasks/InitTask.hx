package hxmake.tasks;


import haxe.io.Path;
import haxe.Template;
import hxmake.cli.CL;
import hxmake.utils.Haxelib;
import sys.FileSystem;
import sys.io.File;

using StringTools;
using hxmake.utils.ArrayTools;

class InitTask extends Task {

	public function new() {
		name = "init";
		description = "Creates `make` folder with simple Module inside";
	}

	override public function run() {
		var moduleDirName:String = project.workingDir.replace("\\", "/").split("/").back();
		// TODO: modulename????
		moduleDirName = moduleDirName.replace(".", "_").replace("/", "_").replace("-", "_");

		var className = 'Module_$moduleDirName';
		CL.workingDir.with(project.workingDir, function() {
			if (FileSystem.exists("make") && FileSystem.isDirectory("make")) {
				project.logger.error("make folder already exists");
				return;
			}

			FileSystem.createDirectory("make");
			var hxmakePath = Haxelib.libPath("hxmake");
			var makeTpl = new Template(File.getContent(Path.join([hxmakePath, "resources/make/LibraryModule.tpl.hx"])));
			var content = makeTpl.execute({});
			content = content.replace("CLASS_NAME", className);
			File.saveContent('make/$className.hx', content);
		});
	}
}
