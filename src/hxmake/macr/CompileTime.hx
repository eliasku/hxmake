package hxmake.macr;

import haxe.macro.Compiler;
import haxe.macro.Expr;
import hxmake.macr.MacroHelper;

@:final
class CompileTime {
	inline public static function log(message:String) {
		#if hxmake_compiler_log
		Sys.println('[MACRO] $message');
		#end
	}
}
