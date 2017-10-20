package hxmake.utils;

@:final
class ArrayTools {
	public static function pushRange<T>(array:Array<T>, elements:Array<T>):Array<T> {
		for(it in elements) {
			array.push(it);
		}
		return array;
	}
}
