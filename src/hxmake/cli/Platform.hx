package hxmake.cli;

@:enum abstract Platform(Int) from Int to Int {

	var UNKNOWN = 0;

	var WINDOWS = 1;
	var MAC = 2;
	var LINUX = 3;

	public var isWindows(get, never):Bool;
	public var isMac(get, never):Bool;
	public var isLinux(get, never):Bool;

	inline function get_isWindows() {
		return this == WINDOWS;
	}

	inline function get_isMac() {
		return this == MAC;
	}

	inline function get_isLinux() {
		return this == LINUX;
	}

	public static function parse(name:String):Platform {
		var platforms = [
			Platform.WINDOWS => ~/window/i,
			Platform.LINUX => ~/linux/i,
			Platform.MAC => ~/mac/i
		];

		for (platform in platforms.keys()) {
			if (platforms.get(platform).match(name)) {
				return platform;
			}
		}

		return Platform.UNKNOWN;
	}
}