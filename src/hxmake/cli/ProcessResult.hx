package hxmake.cli;

using StringTools;

class ProcessResult {

	public var exitCode:Int;
	public var stdout:String = "";
	public var stderr:String = "";

	public function new() {}

	/**
	* Returns all lines from `stdout` in case of success exit code,
	* otherwise returns empty array.
	*
	**/
	public function readLines():Array<String> {
		return exitCode == 0 ? stdout.replace("\r", "").split("\n") : [];
	}
}
