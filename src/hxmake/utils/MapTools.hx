package hxmake.utils;

@:final
class MapTools {
	public static function pushToValueArray<K, V>(map:Map<K, Array<V>>, key:K, value:V):Array<V> {
		var list:Array<V> = map.get(key);
		if (list == null) {
			list = [];
			map.set(key, list);
		}
		list.push(value);
		return list;
	}
}
