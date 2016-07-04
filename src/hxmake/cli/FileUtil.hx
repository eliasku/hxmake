package hxmake.cli;

import haxe.io.Path;
import sys.FileSystem;

@:final
class FileUtil {

	public static function deleteFiles(path:String, filter:String) {
		for (file in FileSystem.readDirectory(path)) {
			var fullPath = Path.join([path, file]);
			if (!FileSystem.isDirectory(fullPath) && checkNameFilter(file, filter)) {
				Debug.log('delete file: $fullPath');
				FileSystem.deleteFile(fullPath);
			}
		}
	}

	static function checkNameFilter(filename:String, filter:String):Bool {
		if (filter.indexOf("*.") == 0) {
			return filename.lastIndexOf(filter.substring(1)) == (filename.length - filter.length + 1);
		}
		return false;
	}
}
