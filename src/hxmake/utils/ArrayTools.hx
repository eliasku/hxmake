package hxmake.utils;

@:final
class ArrayTools {

	public static function pushRange<T>(array:Array<T>, elements:Array<T>):Array<T> {
		for (it in elements) {
			array.push(it);
		}
		return array;
	}

	public static function pushRangeUnique<T>(array:Array<T>, range:Array<T>, ?checkArray:Array<T>):Array<T> {
		if (checkArray == null) checkArray = array;
		for (it in range) {
			if (checkArray.indexOf(it) < 0) {
				array.push(it);
			}
		}
		return array;
	}

	public static function back<T>(array:Array<T>):Null<T> {
		return array.length > 0 ? array[array.length - 1] : null;
	}
}
