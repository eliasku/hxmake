package hxmake.macr;

import haxe.macro.Context;
import haxe.macro.Expr;

@:final
class InitMacro {
	/**
		Generates Main class to run make routine
	**/
	public static function generateMainClass(args:Array<String>) {
		Context.getType("hxmake.core.BuiltInModule");
		var pos = Context.currentPos();
		var fields:Array<Field> = Context.getBuildFields();
		var mainFun:Function = {
			args: [],
			ret: null,
			expr: macro @:privateAccess hxmake.core.ProjectRunner.runFromInitMacro(
				$v{args},
				Sys.getCwd(),
				Sys.args(),
				hxmake.cli.MakeLog.logger
			)
		};
		var main:Field = {
			name: "main",
			access: [AStatic, APublic],
			kind: FFun(mainFun),
			pos: pos
		};
		var typeDef:TypeDefinition = {
			pack: [],
			name: "HxMakeMain",
			pos: pos,
			kind: TypeDefKind.TDClass(),
			fields: [main]
		};
		Context.defineType(typeDef);
	}
}
