package hxmake.cli;

@:final
class PathUtil {

	public static function combine(firstPath:String, secondPath:String):String {
		if (firstPath == null || firstPath == "") {
			return secondPath;
		}
		else if (secondPath != null && secondPath != "") {
			if (CL.platform.isWindows) {
				if (secondPath.indexOf(":") == 1) {
					return secondPath;
				}
			}
			else if (secondPath.substr(0, 1) == "/") {
				return secondPath;
			}

			var firstSlash = (firstPath.substr(-1) == "/" || firstPath.substr(-1) == "\\");
			var secondSlash = (secondPath.substr(0, 1) == "/" || secondPath.substr(0, 1) == "\\");

			if (firstSlash && secondSlash) {
				return firstPath + secondPath.substr(1);
			}
			else if (!firstSlash && !secondSlash) {
				return firstPath + "/" + secondPath;
			}
			return firstPath + secondPath;
		}
		return firstPath;
	}

}
