package hxmake.idea;

import hxmake.utils.XmlAccess;

class IdeaSdkData {

	public var name(default, null):String;
	public var type(default, null):IdeaSdkType;
	public var version(default, null):String;
	public var path(default, null):String;

	public function new(type:IdeaSdkType, name:String, version:String, path:String) {
		this.type = type;
		this.name = name;
		this.version = version;
		this.path = path;
	}

	public static function parseFromXml(xml:XmlAccess):IdeaSdkData {
		if (xml != null) {
			return new IdeaSdkData(
			IdeaSdkType.parse(getNodeAttrValue(xml, "type", "value", "")),
			getNodeAttrValue(xml, "name", "value", ""),
			getNodeAttrValue(xml, "version", "value", ""),
			getNodeAttrValue(xml, "homePath", "value", "")
			);
		}
		return null;
	}

	static function getNodeAttrValue(xml:XmlAccess, nodeName:String, attName:String, defaultValue:String):String {
		if (xml.hasNode.resolve(nodeName)) {
			var typeNode:XmlAccess = xml.node.resolve(nodeName);
			if (typeNode.has.resolve(attName)) {
				return typeNode.att.resolve(attName);
			}
		}
		return defaultValue;
	}
}
