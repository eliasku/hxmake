package hxmake.macr;

import haxe.macro.Compiler;
import haxe.macro.Expr;
import hxmake.macr.MacroHelper;

class CompileTime {

	macro public static function readFile(path:String):ExprOf<String> {
		return MacroHelper.toExpr(MacroHelper.loadFileAsString(path));
	}

	public static function addMakePath(makePath:String) {
		Compiler.addClassPath(makePath);
		Compiler.include("", true, null, [makePath]);
	}

	public static function log(message:String) {
		#if hxmake_compiler_log
		Sys.println('[MACRO] $message');
		#end
	}
}
