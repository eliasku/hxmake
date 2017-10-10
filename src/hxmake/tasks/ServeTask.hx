package hxmake.tasks;

import hxmake.cli.CL;
import hxmake.Task;
import sys.io.Process;

class ServeTask extends Task {

	public var host:String;
	public var port:Int;

	/**
	* Path to open (http://host:port/{PATH})
	**/
	public var index:String;

	/**
	* Path to directory to serve
	**/
	public var wwwPath:String;

	var _process:Process;

	public function new(host:String = "localhost", port:Int = 2000, index:String = "", wwwPath:String = ".") {
		name = "serve";
		description = "Start local http server to serve file system content";
		this.port = port;
		this.host = host;
		this.index = index;
		this.wwwPath = wwwPath;
	}

	override public function configure() {}

	override public function run() {
		serve();
		if (_process != null) {
			navigateUrl('http://$host:$port/$index');
			var ec = _process.exitCode();
		}
	}

	function serve() {
		_process = new Process("nekotools", ["server", "-p", Std.string(port), "-h", host, "-d", wwwPath]);
		try {
			#if neko
			Sys.sleep(1);
			#end
		}
		catch (e:Dynamic) {
			fail(Std.string(e));
		}
	}

	// TODO: move to utilities?
	public static function navigateUrl(url:String) {
		var args = [url];
		if (CL.platform.isWindows) {
			Sys.command("start", args);
		}
		else {
			Sys.command("open", args);
		}
	}
}