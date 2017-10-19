package hxmake.core;

import hxmake.cli.logging.Logger;
import hxmake.cli.logging.LogLevel;

/**
	Provides utility for debug output
**/
@:final
class Printer {

	var _logger:Logger;

	public function new(logger:Logger) {
		_logger = logger;
	}

	public function printCompilerMode(isCompiler:Bool, level:LogLevel = LogLevel.TRACE) {
		if (isCompiler) _logger.print("Running in Compiler mode", level);
	}

	public function printArguments(arguments:Arguments, level:LogLevel = LogLevel.TRACE) {
		var map = arguments.propertyMap;
		var keys = [for (key in map.keys()) key];
		if (keys.length > 0) {
			_logger.print("Running with properties:", level);
			for (key in keys) {
				_logger.print('\t$key = [${arguments.propertyValues(key).join(", ")}]', level);
			}
		}
	}

	public function printModules(modules:Array<Module>, level:LogLevel = LogLevel.TRACE) {
		var names = modules.map(function(m:Module) return m.name);
		if (names.length == 0) _logger.error("Modules not found");
		else _logger.print("Modules: " + names.join(", "), level);
	}
}