package hxmake.cli;

import haxe.Log;
import haxe.PosInfos;
import hxmake.cli.logging.Logger;
import hxmake.cli.logging.LogLevel;

@:final
class MakeLog {

	public static var logger(default, null):Logger = new Logger();

	public inline static function trace(message:Any, ?position:PosInfos) {
		logger.trace(message, position);
	}

	public inline static function debug(message:Any, ?position:PosInfos) {
		logger.debug(message, position);
	}

	public inline static function info(message:Any, ?position:PosInfos) {
		logger.info(message, position);
	}

	public inline static function warning(message:Any, ?position:PosInfos) {
		logger.warning(message, position);
	}

	public inline static function error(message:Any, ?position:PosInfos) {
		logger.error(message, position);
	}

	public static function initialize(args:Array<String>) {
		if(args.indexOf("--silent") >= 0) {
			logger.setFilter(LogLevel.FILTER_SILENT);
		}
		else if(args.indexOf("--verbose") >= 0) {
			logger.setFilter(LogLevel.FILTER_VERBOSE);
		}
		Log.trace = onHaxeTrace;
	}

	static function onHaxeTrace(message:Any, ?position:PosInfos) {
		trace(message, LogLevel.TRACE, position);
	}
}
