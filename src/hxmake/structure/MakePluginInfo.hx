package hxmake.structure;

import haxe.DynamicAccess;

typedef MakePluginInfo = {
	@:optional var src:Array<String>;
	@:optional var lib:DynamicAccess<String>;
}
