package hxmake.cli;

import hxlog.Log;
import hxlog.LogTarget;
import hxlog.format.AnsiColorsFormatter;
import hxlog.sys.SysOutput;

@:final
class LogConfig {
	public static function initialize() {
		var target = new LogTarget();
		target.format(new AnsiColorsFormatter());
		target.out(new SysOutput());
		Log.manager.add(target);
		Log.manager.handleHaxeTrace = true;
	}
}
