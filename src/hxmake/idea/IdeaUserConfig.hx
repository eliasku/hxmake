package hxmake.idea;

import hxmake.cli.Debug;
import hxmake.cli.CL;
import sys.io.File;
import haxe.xml.Fast;
import sys.FileSystem;
import haxe.io.Path;

class IdeaUserConfig {

	static inline var IDEA_VERSION_START:Int = 15;
	static inline var IDEA_VERSION_END:Int = 20;

	public var path(default, null):String;

	public var flexSdkList:Array<String> = [];
	public var haxeSdkList:Array<String> = [];

	public function new() {
		path = getIdeaConfigPath();
		if (path != null) {
			var jdkTableContent = File.getContent(Path.join([path, "options", "jdk.table.xml"]));
			var jdkTableXml = Xml.parse(jdkTableContent);
			var fast = new Fast(jdkTableXml.firstElement());
			for (c in fast.nodes.component) {
				for (j in c.nodes.jdk) {
					var type = j.node.type.att.value;
					var name = j.node.name.att.value;
					if (type.indexOf("Flex") == 0) {
						flexSdkList.push(name);
					}
					else if (type.indexOf("Haxe") == 0) {
						haxeSdkList.push(name);
					}
				}
			}
		}

		if (flexSdkList.length == 0) {
			flexSdkList.push("AIR_SDK");
		}

		if (haxeSdkList.length == 0) {
			haxeSdkList.push("Haxe 3.2.0");
		}
	}

	public function getHaxeSdkName():String {
		return haxeSdkList[haxeSdkList.length - 1];
	}

	public function getFlexSdkName():String {
		return flexSdkList[flexSdkList.length - 1];
	}

	static function getIdeaConfigPath() {
		var userHome = CL.getUserHome();
		var folderName = ".IntelliJIdea";
		if (CL.platform.isMac) {
			userHome = Path.join([userHome, "Library", "Preferences"]);
			folderName = "IntelliJIdea";
		}

		Debug.log('Search IntelliJ IDEA Preferences in: $userHome');

		var v = IDEA_VERSION_END;
		var sv = ["", ".1"];
		var pv = ["", "20"];
		var svi = 0;
		while (v >= IDEA_VERSION_START) {
		  for(svi in 0...sv.length) {
		  for(pvi in 0...pv.length) {
			var path = Path.join([userHome, folderName + pv[pvi] + v + sv[svi]]);
			if (!CL.platform.isMac) {
				path = Path.join([path, "config"]);
			}
			if (FileSystem.exists(path) && FileSystem.isDirectory(path)) {
				Debug.log("Found IntelliJ Idea config folder: " + path);
				var innerPath = Path.join([path, "options", "jdk.table.xml"]);
				// check if it contains valid options
				if (FileSystem.exists(innerPath) && !FileSystem.isDirectory(innerPath)) {
					return path;
				}
			}
			}
			}
			--v;
		}
		Debug.log("IntelliJ Idea configuration is not found");
		return null;
	}
}
