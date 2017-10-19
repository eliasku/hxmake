package hxmake.core;

import hxmake.utils.MapTools;

/**
	Parse arguments and provides access to properties and tasks
**/
@:final
class Arguments {

	public var args(default, null):Array<String>;
	public var propertyMap(default, null):Map<String, Array<String>>;
	public var tasks(default, null):Array<String>;

	public function new(args:Array<String>) {
		this.args = args.copy();
		propertyMap = parsePropertyMap(this.args);
		tasks = parseTasks(this.args);
	}

	/**
	* Read property value from running Arguments
	* For example, `property("--build")` call:
	* 1) for arguments `--build=VALUE`, will return `VALUE`
	* 2) for argument `--build`, will return empty string
	* 3) if argument is not found, will return `null`
	*
	* @name - name of property (for example `--build`)
	* @returns - property value or Null of property is not provided
	**/
	public function property(name:String):Null<String> {
		var values = propertyValues(name);
		return values.length > 0 ? values[0] : null;
	}

	public function propertyValues(name:String):Array<String> {
		return propertyMap.exists(name) ? propertyMap.get(name) : [];
	}

	public function hasProperty(name:String):Bool {
		return property(name) != null;
	}

	/**
		Creates Dynamic object with keys and joined values
	**/
	public function propertiesToDynamic(separator:String = ","):Dynamic<String> {
		var data:Dynamic = {};
		for (key in propertyMap.keys()) {
			Reflect.setField(data, key, propertyValues(key).join(separator));
		}
		return data;
	}

	static function parsePropertyMap(args:Array<String>):Map<String, Array<String>> {
		var props = new Map();
		var re = ~/^(-[^=]+)[=]?(.*)?/;
		for (arg in args) {
			if (re.match(arg)) {
				MapTools.pushToValueArray(props, re.matched(1), re.matched(2));
			}
		}
		return props;
	}

	static function parseTasks(args:Array<String>):Array<String> {
		var result:Array<String> = [];
		for (arg in args) {
			if (arg.charAt(0) != "-") {
				result.push(arg);
			}
		}
		return result;
	}
}
