package hxmake.cli;

import hxlog.Log;
import haxe.io.Path;
import sys.FileSystem;

@:final
class FileUtil {

	public static function deleteFiles(path:String, filter:String) {
		for (file in FileSystem.readDirectory(path)) {
			var fullPath = Path.join([path, file]);
			if (!FileSystem.isDirectory(fullPath) && checkNameFilter(file, filter)) {
				Log.trace('delete file: $fullPath');
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

	public static function getFilesRecursiveFromArray(pathList:Array<String>, filters:Array<EReg>, ?out:Array<String>):Array<String> {
		if (out == null) {
			out = [];
		}

		for (path in pathList) {
			getFilesRecursive(path, filters, out);
		}

		return out;
	}

	public static function getFilesRecursive(path:String, filters:Array<EReg>, ?out:Array<String>):Array<String> {
		if (out == null) {
			out = [];
		}

		if (!FileSystem.exists(path)) {
			return out;
		}

		for (filter in filters) {
			if (filter.match(path)) {
				return out;
			}
		}

		if (!FileSystem.isDirectory(path)) {
			out.push(path);
			return out;
		}

		var files = FileSystem.readDirectory(path);
		for (file in files) {
			var absPath = Path.join([path, file]);
			getFilesRecursive(absPath, filters, out);
		}

		return out;
	}

	// TODO: better implementation
	public static function pathEquals(path1:String, path2:String):Bool {
		return StringTools.replace(path1, "\\", "/") == StringTools.replace(path2, "\\", "/");
	}
}
