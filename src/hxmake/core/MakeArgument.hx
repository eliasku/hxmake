package hxmake.core;

@:enum abstract MakeArgument(String) to String from String {
	// Enables `debug` and `trace` log levels
	var VERBOSE = "--verbose";

	// Mute logger output
	var SILENT = "--silent";

	// Enables compile-time logging from `CompileTime.log`
	var MAKE_COMPILER_LOG = "--make-compiler-log";

	// Show Haxe compiler time statistics, adds `--times -D macro-times`
	var MAKE_COMPILER_TIME = "--make-compiler-time";

	// Rebuild `hxmake` binary and re-install alias-script
	var TASK_REBUILD = "_";
}
