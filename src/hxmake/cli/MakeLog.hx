package hxmake.cli;

import haxe.Log;
import haxe.PosInfos;
import hxmake.cli.logging.Logger;

@:final
class MakeLog {

	public static var logger(get, never):Logger;

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

	static function onHaxeTrace(message:Dynamic, ?position:PosInfos) {
		_logger.trace(message, position);
	}

	static var _logger:Logger;

	static function get_logger():Logger {
		if (_logger == null) {
			_logger = new Logger();
			Log.trace = onHaxeTrace;
		}
		return _logger;
	}
}
