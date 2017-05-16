package hxmake.cli;

import haxe.Log;
import haxe.PosInfos;
import hxmake.cli.logging.Logger;
import hxmake.cli.logging.LogLevel;

@:final
class MakeLog {

	public static var logger(default, null):Logger = new Logger();

	public inline static function trace(message:Dynamic, ?position:PosInfos) {
		logger.trace(message, position);
	}

	public inline static function debug(message:Dynamic, ?position:PosInfos) {
		logger.debug(message, position);
	}

	public inline static function info(message:Dynamic, ?position:PosInfos) {
		logger.info(message, position);
	}

	public inline static function warning(message:Dynamic, ?position:PosInfos) {
		logger.warning(message, position);
	}

	public inline static function error(message:Dynamic, ?position:PosInfos) {
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

	static function onHaxeTrace(message:Dynamic, ?position:PosInfos) {
		trace(message, LogLevel.TRACE, position);
	}
}
