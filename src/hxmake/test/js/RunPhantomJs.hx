package hxmake.test.js;

import haxe.io.Path;
import haxe.Template;
import hxmake.cli.CL;
import hxmake.utils.Haxelib;
import sys.io.File;
import sys.io.Process;

class RunPhantomJs extends RunTask {

	public var jsPath:String;

	public function new(jsPath:String) {
		super();
		this.jsPath = jsPath;
	}

	override public function run() {
		var jsDir = Path.directory(jsPath);
		var htmlPath = Path.join([jsDir, "phantomjs.html"]);
		var hxmakePath = Haxelib.libPath("hxmake");
		var html = genFile(File.getContent(Path.join([hxmakePath, "resources/phantomjs/phantomjs.html"])), {
			jsFile: Path.withoutDirectory(jsPath)
		});
		File.saveContent(htmlPath, html);

		var runnerPath = Path.join([jsDir, "phantomjs.js"]);
		var runnerJs = File.getContent(Path.join([hxmakePath, "resources/phantomjs/phantomjs.js"]));
		File.saveContent(runnerPath, runnerJs);

		command = "phantomjs";
		arguments = [runnerPath];

		var process = new Process("nekotools", ["server", "-p", "2000", "-h", "localhost", "-d", jsDir]);
		try {
			Sys.sleep(0.5);
			execute();
			if (exitCode != 0) {
				fail();
			}
			closeServer(process);
		}
		catch (e:Dynamic) {
			closeServer(process);
			throw e;
		}
	}

	static function closeServer(process:Process) {
		if (CL.platform.isWindows) {
			process.kill();
		}
		else {
			process.close();
		}
	}

	static function genFile(tpl:String, context:Dynamic) {
		var tmpl = new Template(tpl);
		return tmpl.execute(context);
	}
}
