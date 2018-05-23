package hxmake;

import haxe.DynamicAccess;

typedef ModuleConfig = {

	@:optional var classPath:Array<String>;
	@:optional var testPath:Array<String>;
	@:optional var makePath:Array<String>;

	/**
	 * Depedencies map.
	 * Examples:
	 * "{DEPENDENCY_NAME}" => "haxelib" - means install latest version of {DEPENDENCY_NAME} from haxelib
	 * "{DEPENDENCY_NAME}" => "haxelib:1.0.0" - means version 1.0.0 of {DEPENDENCY_NAME} from haxelib
	 * "{DEPENDENCY_NAME}" => "haxelib:git:{URL}#[{BRANCH}]#[{SUB_DIR}]#[{VERSION}]" means install git version of {DEPENDENCY_NAME}
	 * "{DEPENDENCY_NAME}" => "haxelib:hg:{URL}#[{BRANCH}]#[{SUB_DIR}]#[{VERSION}]" means install mercurial version of {DEPENDENCY_NAME}
	 * // TODO: Please remove warning once this haxelib start support this.
	 * @warning Please be care as generated haxelib.json doesn't support Mercurial repositories and Sub directories and Versions for git repo
	 **/
	@:optional var dependencies:DynamicAccess<String>;
	@:optional var devDependencies:DynamicAccess<String>;
}
