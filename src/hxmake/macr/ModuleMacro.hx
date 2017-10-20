package hxmake.macr;

import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr.Access;
import haxe.macro.Expr;
import haxe.macro.Type;
import sys.FileSystem;

using StringTools;

class ModuleMacro {

	public static function build():Array<Field> {
		var cls:ClassType = Context.getLocalClass().get();
		var pos = Context.currentPos();
		var fields:Array<Field> = Context.getBuildFields();
		cls.meta.add(":keep", [], pos);
		var modulePath = getModulePath(Context.getLocalModule());
		var childrenExprs:Array<Expr> = [];

		CompileTime.log(modulePath);

		// TODO: readme @:module_path
		var changedModulePath:Array<String> = MacroHelper.extractMetaStrings(cls.meta, ":module_path");
		if (changedModulePath.length > 0) {
			var parentPath = modulePath;
			modulePath = FileSystem.absolutePath(Path.join([modulePath, changedModulePath[0]]));
			CompileTime.log("CHANGED TO: " + modulePath);
		}

		var guessModuleName = modulePath.split("/").pop();

		// TODO: readme @:include
		var includesPositions:Array<Position> = [];
		var includes:Array<String> = MacroHelper.extractMetaStrings(cls.meta, ":include", includesPositions);
		for (i in 0...includes.length) {
			var include = includes[i];
			var includePos = includesPositions[i];
			var childModulePath = FileSystem.absolutePath(Path.join([modulePath, include]));
			if (!FileSystem.exists(childModulePath)) {
				Context.warning('Path is not found for include "$include"', includePos);
				continue;
			}

			var cp = Path.join([childModulePath, "make"]);
			if (FileSystem.exists(cp)) {
				PluginInclude.scan(cp);
				CompileTime.addMakePath(cp);
			}
			// TODO: post check?
			//else {
			//Context.warning('Make directory is not found for module "$include"', includePos);
			//}

			childrenExprs.push(macro hxmake.core.CompiledProjectData.CURRENT.connect($v{modulePath}, $v{childModulePath}));
		}

		// TODO: readme @:lib
		processMakeLibraries(":lib", cls.meta);

		if (!cls.meta.has(":root")) {
			var parentMakeDir = FileSystem.absolutePath(Path.join([modulePath, "..", "make"]));
			if (FileSystem.exists(parentMakeDir) && FileSystem.isDirectory(parentMakeDir)) {
				PluginInclude.scan(parentMakeDir);
				CompileTime.addMakePath(parentMakeDir);
			}
		}

		var tp = {
			name: cls.name,
			pack: cls.pack
		};

		fields.push(MacroHelper.makeInitField(macro {
			var module = @:privateAccess new $tp();
			if(module.name == null) {
				module.name = $v{guessModuleName};
			}
			module.path = $v{modulePath};
			hxmake.core.CompiledProjectData.CURRENT.addModule(module);
			$b{childrenExprs}
		}, pos));

		transformConstructor(fields);

		return fields;
	}

	static function processMakeLibraries(libraryMeta:String, metaAccess:MetaAccess) {
		var metaList:Array<MetadataEntry> = metaAccess.extract(libraryMeta);
		for (meta in metaList) {
			if (meta.params.length > 0) {
				var libName = exprGetStringConst(meta.params[0]);
				var libPath = exprGetStringConst(meta.params[1]);
				if (libName == null) {
					throw '@$libraryMeta first argument need to be String literal';
				}
				PluginInclude.include(libName, libPath);
			}
			else {
				throw '@$libraryMeta requires at least one argument';
			}
		}
	}

	static function exprGetStringConst(expr:Expr):Null<String> {
		if (expr == null) {
			return null;
		}
		return switch(expr.expr) {
			case EConst(x):
				switch(x) {
					case CString(y): y;
					case _: null;
				}
			case _: null;
		}
	}

	static function transformConstructor(fields:Array<Field>) {
		for (field in fields) {
			if (field.name == "new") {
				field.name = "__initialize";
				field.access = [Access.AOverride];
				// TODO: add more validation at Compile-time
			}
		}

		// and generate default empty constructor as well
		fields.push(MacroHelper.makeEmptyConstructor(Context.currentPos()));
	}

	static function getModulePath(haxeModulePath:String) {
		var moduleRelativePath = haxeModulePath.replace(".", "/") + ".hx";
		var depth = moduleRelativePath.split("/").length + 1;
		var modulePath:String = Context.resolvePath(moduleRelativePath);
		modulePath = modulePath.replace("\\", "/");
		var parts = modulePath.split("/");
		parts = parts.slice(0, parts.length - depth);
		return parts.join("/");
	}
}
