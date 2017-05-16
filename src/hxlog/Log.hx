package hxlog;

import hxmake.cli.MakeLog;
import haxe.PosInfos;

/**
	DEPRECATED! Kept for backward compatability.
**/
@:final
@:deprecated("hxlog had been removed from hxmake dependencies, Use hxmake.cli.MakeLog")
class Log {

	@:deprecated("Use hxmake.cli.MakeLog")
	public inline static function trace(message:Dynamic, ?position:PosInfos) {
		MakeLog.trace(message, position);
	}

	@:deprecated("Use hxmake.cli.MakeLog")
	public inline static function debug(message:Dynamic, ?position:PosInfos) {
		MakeLog.debug(message, position);
	}

	@:deprecated("Use hxmake.cli.MakeLog")
	public inline static function info(message:Dynamic, ?position:PosInfos) {
		MakeLog.info(message, position);
	}

	@:deprecated("Use hxmake.cli.MakeLog")
	public inline static function warning(message:Dynamic, ?position:PosInfos) {
		MakeLog.warning(message, position);
	}

	@:deprecated("Use hxmake.cli.MakeLog")
	public inline static function error(message:Dynamic, ?position:PosInfos) {
		MakeLog.error(message, position);
	}
}
