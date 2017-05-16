package hxmake.cli.logging;

@:enum abstract LogLevel(Int) to Int {
	var TRACE = 0;
	var DEBUG = 1;
	var INFO = 2;
	var WARNING = 3;
	var ERROR = 4;

	public static inline var FILTER_SILENT = 0;
	public static inline var FILTER_VERBOSE = 0xFF;
	public static inline var FILTER_STD = (1 << INFO) | (1 << WARNING) | (1 << ERROR);
}
