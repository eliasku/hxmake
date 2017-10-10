package hxmake.cli;

import haxe.Log;
import haxe.PosInfos;
import hxmake.cli.logging.Logger;
import hxmake.cli.logging.LogLevel;

@:final
class MakeLog {

	public static var logger(default, null):Logger;

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

	public static function initialize(silent:Bool, verbose:Bool) {
		var filter = LogLevel.FILTER_STD;
		if(verbose) filter = LogLevel.FILTER_VERBOSE;
		if(silent) filter = LogLevel.FILTER_SILENT;
		logger = new Logger(filter);
		Log.trace = onHaxeTrace;
	}

	static function onHaxeTrace(message:Dynamic, ?position:PosInfos) {
		trace(message, LogLevel.TRACE, position);
	}
}
