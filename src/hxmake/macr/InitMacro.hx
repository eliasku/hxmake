package hxmake.macr;

import haxe.macro.Compiler;
import haxe.macro.Expr;
import haxe.macro.Context;

class InitMacro {
	public static function generateMainClass(initialMakeDir:String, isCompiler:Bool, args:Array<String>) {
		PluginInclude.scan(initialMakeDir);
		Compiler.addClassPath(initialMakeDir);
		Compiler.include("", true, null, [initialMakeDir]);

		var pos = Context.currentPos();
		var fields:Array<Field> = Context.getBuildFields();
		var mainFun:Function = {
			args: [],
			ret: null,
			expr: macro {
				var prj = new hxmake.Project($v{args}, $v{isCompiler});
				prj.run();
			}
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
			meta: [{name: ":access", params: [macro hxmake.Project], pos: pos}],
			//@:optional var params : Array<TypeParamDecl>;
			//@:optional var isExtern : Bool;
			kind: TypeDefKind.TDClass(),
			fields: [main]
		};
		Context.defineType(typeDef);
	}
}
