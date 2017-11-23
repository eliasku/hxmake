package hxmake.idea;

@:enum abstract IdeaSdkType(String) to String from String {
	var UNKNOWN = "Unknown";
	var FLEX = "Flex";
	var HAXE = "Haxe";

	public static function parse(str:String) {
		if (str.indexOf(FLEX) >= 0) return FLEX;
		if (str.indexOf(HAXE) >= 0) return HAXE;
		return UNKNOWN;
	}
}
