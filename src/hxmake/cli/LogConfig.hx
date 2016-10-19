package hxmake.cli;

import hxlog.Log;
import hxlog.bending.AnsiColoringBend;
import hxlog.logging.SysLog;

@:final
class LogConfig {
	public static function initialize() {
		Log.manager.branch().bend(new AnsiColoringBend()).bend(new SysLog());
		Log.manager.handleHaxeTrace = true;
	}
}
