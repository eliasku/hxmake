package hxmake.idea;

import haxe.xml.Fast;
class IdeaSdkData {
	public var type(default, null):String;
	public var name(default, null):String;
	public var version(default, null):String;
	public var path(default, null):String;

	public function new(type:String, name:String, version:String, path:String) {
		this.type = type;
		this.name = name;
		this.version = version;
		this.path = path;
	}

	public function is(value:String):Bool {
		return type.indexOf(value) == 0;
	}

	public static function parseFromXml(xml:Fast):IdeaSdkData {
		if (xml != null) {
			return new IdeaSdkData(
			getNodeValue(xml, "type", "value", ""),
			getNodeValue(xml, "name", "value", ""),
			getNodeValue(xml, "version", "value", ""),
			getNodeValue(xml, "homePath", "value", "")
			);
		}
		return null;
	}

	static function getNodeValue(xml:Fast, nodeName:String, attName:String, defaultValue:String):String {
		if (xml.hasNode.resolve(nodeName)) {
			var typeNode:Fast = xml.node.resolve(nodeName);
			if (typeNode.has.resolve(attName)) {
				return typeNode.att.resolve(attName);
			}
		}
		return defaultValue;
	}
}
