package hxmake.structure;

import hxmake.cli.MakeLog;

class PackageTools {

	public static function getRoot(pack:PackageData):PackageData {
		while (pack._parent != null) {
			pack = pack._parent;
		}
		return pack;
	}

	public static function print(pack:PackageData, depth:Int = 0) {
		var ind = "*";
		for (i in 0...depth) ind += "-";
		MakeLog.info(ind + " " + (pack.name != null ? (pack.name + " @ " + pack.path) : "NULL"));
		if (pack._children != null) {
			for (child in pack._children) {
				print(child, depth + 1);
			}
		}
	}

	public static function addChild(pack:PackageData, child:PackageData) {
		pack._children.push(child);
		child._parent = pack;
	}
}
