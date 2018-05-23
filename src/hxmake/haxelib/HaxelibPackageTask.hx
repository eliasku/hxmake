package hxmake.haxelib;

import haxe.io.Bytes;
import haxe.io.Path;
import haxe.zip.Entry;
import haxe.zip.Writer;
import hxmake.cli.FileUtil;
import sys.FileSystem;
import sys.io.File;

class HaxelibPackageTask extends Task {

	public function new() {
		description = "Zip haxe library package";
	}

	override public function run() {
		var ext:HaxelibConfig = module.getExtConfig("haxelib");

		if (ext != null && module.isActive) {
			packageFiles(ext);
		}
	}

	public static var HIDDEN_FILES(default, null):EReg = ~/\.(svn)|(git)|(DS_Store)|(tmbuild)/;

	function packageFiles(ext:HaxelibConfig) {

		var ignoreFilters = [HIDDEN_FILES];
		if (ext.packageFilter != null) {
			for (filterString in ext.packageFilter) {
				ignoreFilters.push(new EReg(filterString, ""));
			}
		}

		var files = FileUtil.getFilesRecursiveFromArray(ext.packageInclude, ignoreFilters);
		var zipEntries = getZipEntries(files);
		var zipName = module.name + ".zip";
		var zip = File.write(zipName, true);
		var writer:Writer = new Writer(zip);
		writer.write(zipEntries);
		zip.close();
	}

	public static function getZipEntries(files:Array<String>):List<Entry> {
		var entries:List<Entry> = new List();
		var date = Date.now();
		for (file in files) {
			var stat = FileSystem.stat(file);
			var isDir = FileSystem.isDirectory(file);
			var bytes:Bytes = isDir ? null : File.getBytes(file);
			var name:String = isDir ? (Path.directory(file) + "/") : file;

			var entry:Entry = {
				fileTime: date,
				fileName: name,
				fileSize: stat.size,
				data: bytes,
				dataSize: bytes != null ? bytes.length : 0,
				compressed: false,
				crc32: 0,
				extraFields: new List()
			}

			entries.add(entry);
		}

		return entries;
	}

}
