package hxmake.cli.logging;

@:enum abstract AnsiColor(String) to String {
	var BLACK = "\033[0;30m";
	var RED = "\033[31m";
	var GREEN = "\033[32m";
	var YELLOW = "\033[33m";
	var BLUE = "\033[1;34m";
	var MAGENTA = "\033[1;35m";
	var CYAN = "\033[0;36m";
	var GREY = "\033[0;37m";
	var WHITE = "\033[1;37m";
	var RESET = "\033[0m";
}