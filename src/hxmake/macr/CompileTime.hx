package hxmake.macr;

import hxmake.macr.MacroHelper;
import haxe.macro.Expr;

class CompileTime {
	macro public static function readFile(path:String):ExprOf<String> {
		return MacroHelper.toExpr(MacroHelper.loadFileAsString(path));
	}
}
