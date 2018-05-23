package hxmake.haxelib;

typedef HaxelibConfig = {

	@:optional var name:String;
	@:optional var description:String;
	@:optional var version:String;
	@:optional var releasenote:String;
	@:optional var contributors:Array<String>;
	@:optional var license:String;
	@:optional var url:String;
	@:optional var tags:Array<String>;

	/** plugin options **/

	@:optional var library:Bool;

	@:default(false)
	@:optional var updateJson:Bool;

	@:default(false)
	@:optional var installDev:Bool;

	/** packaging config **/
	@:optional var packageFilter:Array<String>;
	@:optional var packageInclude:Array<String>;
}
