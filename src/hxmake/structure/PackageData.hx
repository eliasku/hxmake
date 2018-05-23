package hxmake.structure;

import haxe.DynamicAccess;

typedef PackageData = {
	@:optional var name:String;

	@:optional var path:String;
	@:optional var root:Bool;
	@:optional var include:Array<String>;
	@:optional var libraries:DynamicAccess<String>;
	@:optional var external:Array<PackageData>;
	@:optional var makeplugin:MakePluginInfo;

	/**
		Add tasks to module
	**/
	@:optional var tasks:DynamicAccess<String>;

	/**
		List of initialize classes
	**/
	@:optional var init:Array<String>;

	@:optional var _parent:PackageData;
	@:optional var _children:Array<PackageData>;
}
