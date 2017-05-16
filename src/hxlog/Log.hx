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
	public inline static function trace(message:Any, ?position:PosInfos) {
		MakeLog.trace(message, position);
	}

	@:deprecated("Use hxmake.cli.MakeLog")
	public inline static function debug(message:Any, ?position:PosInfos) {
		MakeLog.debug(message, position);
	}

	@:deprecated("Use hxmake.cli.MakeLog")
	public inline static function info(message:Any, ?position:PosInfos) {
		MakeLog.info(message, position);
	}

	@:deprecated("Use hxmake.cli.MakeLog")
	public inline static function warning(message:Any, ?position:PosInfos) {
		MakeLog.warning(message, position);
	}

	@:deprecated("Use hxmake.cli.MakeLog")
	public inline static function error(message:Any, ?position:PosInfos) {
		MakeLog.error(message, position);
	}
}
