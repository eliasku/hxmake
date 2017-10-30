package hxmake.utils;

@:final
class ArrayTools {

	public static function pushRange<T>(array:Array<T>, elements:Array<T>):Array<T> {
		for (it in elements) {
			array.push(it);
		}
		return array;
	}

	public static function back<T>(array:Array<T>):Null<T> {
		return array.length > 0 ? array[array.length - 1] : null;
	}
}
