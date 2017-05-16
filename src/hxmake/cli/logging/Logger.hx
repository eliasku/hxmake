package hxmake.cli.logging;

import hxmake.cli.logging.AnsiColor;
import haxe.Log;
import haxe.PosInfos;

class Logger {

	public static var current(default, null):Logger = new Logger();

	var _filter:Int;
	var _colors:Array<AnsiColor> = [];
	var _levels:Array<String> = [];
	var _positions:Array<Bool> = [];

	public function new() {
		setLevelFormat(LogLevel.TRACE, "[T] ", AnsiColor.GREY, true);
		setLevelFormat(LogLevel.DEBUG, "[D] ", AnsiColor.WHITE, true);
		setLevelFormat(LogLevel.INFO, "", AnsiColor.CYAN, false);
		setLevelFormat(LogLevel.WARNING, "[WARNING] ", AnsiColor.YELLOW, false);
		setLevelFormat(LogLevel.ERROR, "[ERROR] ", AnsiColor.RED, false);
		setFilter(LogLevel.FILTER_STD);
	}

	inline public function trace(message:Any, ?position:PosInfos) {
		print(message, LogLevel.TRACE, position);
	}

	inline public function debug(message:Any, ?position:PosInfos) {
		print(message, LogLevel.DEBUG, position);
	}

	inline public function info(message:Any, ?position:PosInfos) {
		print(message, LogLevel.INFO, position);
	}

	inline public function warning(message:Any, ?position:PosInfos) {
		print(message, LogLevel.WARNING, position);
	}

	inline public function error(message:Any, ?position:PosInfos) {
		print(message, LogLevel.ERROR, position);
	}

	public function print(text:String, level:LogLevel, ?position:PosInfos) {
		if((_filter & (1 << level)) == 0) {
			return;
		}

		if(_positions[level]) {
			text = position.fileName + ":" + position.lineNumber + " ";
		}

		Sys.println(_colors[level] + _levels[level] + text + AnsiColor.RESET);
	}

	public function setFilter(filter:Int) {
		_filter = filter;
	}

	public function setLevelFormat(level:LogLevel, prefix:String, color:AnsiColor, position:Bool) {
		_colors[level] = color;
		_levels[level] = prefix;
		_positions[level] = position;
	}
}