package hxmake.macr;

import haxe.macro.Type.MetaAccess;
import haxe.macro.Expr;
import haxe.macro.Context;

@:final
class MacroHelper {
#if macro
	public static function loadFileAsString(path:String) {
		try {
			var p = Context.resolvePath(path);
			Context.registerModuleDependency(Context.getLocalModule(),p);
			return sys.io.File.getContent(p);
		}
		catch(e:Dynamic) {
			return haxe.macro.Context.error('Failed to load file $path: $e', Context.currentPos());
		}
	}

	public static function toExpr(v:Dynamic) {
		return Context.makeExpr(v, Context.currentPos());
	}

	public static function makeInitField(expr:Expr, pos:Position):Field {
		return {
			name: "__init__",
			access: [AStatic],
			kind: FFun({args: [], expr: expr, ret: null}),
			pos: pos
		};
	}

	public static function makeEmptyConstructor(pos:Position):Field {
		return {
			name: "new",
			access: [],
			kind: FFun({args: [], expr: macro{}, ret: null}),
			pos: pos
		};
	}

	public static function extractMetaStrings(metaAccess:MetaAccess, name:String):Array<String> {
		var result:Array<String> = [];
		var metaList:Array<MetadataEntry> = metaAccess.extract(name);
		for(meta in metaList) {
			for(param in meta.params) {
				result.push(
					switch(param.expr) {
						case EConst(x):
							switch(x) {
								case CString(y):
									y;
								case _: throw "Meta param must be string constant";
							}
						case _: throw "Meta param must be string constant";
					}
				);
			}
		}
		return result;
	}
#end
}
