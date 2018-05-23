package hxmake.structure;

import haxe.io.Path;
import haxe.Json;
import hxmake.cli.FileUtil;
import hxmake.cli.MakeLog;
import hxmake.json.JSMin;
import hxmake.utils.Haxelib;
import hxmake.utils.Hxml;
import sys.io.File;

using hxmake.structure.PackageTools;

class StructureBuilder {

	public var firstParentDirDepthLimit:Int = 5;
	public var parentDirDepthLimit:Int = 2;
	public var configFiles:Array<String> = ["hxmake.json"];
//	public var scanForFolders:Array<String> = ["make", "makeplugin"];

	public var packages(default, null):Map<String, PackageData> = new Map();
	public var root(default, null):PackageData;

	public function new(path:String) {
		var dir = Path.normalize(path);
		MakeLog.info("Search project in path: " + dir);
		visitFirst(dir);

		var rootMap = new Map<String, PackageData>();
		for (pack in packages) {
			var root = pack.getRoot();
			rootMap.set(root.path, root);
		}

		root = {
			_children: [for (r in rootMap) r]
		};
		root.print();
	}

	function visitFirst(path:String) {
		var node = visit(path);
		if (node == null) {
			visitParent(path, firstParentDirDepthLimit);
		}
	}

	function visit(path:String):PackageData {
		if (packages.exists(path)) {
			return packages.get(path);
		}
		var pack = createPackage(path);
		if (pack != null) {
			visitNode(pack);
			return pack;
		}
		return null;
	}

	function visitNode(pack:PackageData) {
		packages.set(pack.path, pack);
		if (pack.external != null) {
			for (extPack in pack.external) {
				visitNode(extPack);
			}
		}
		if (!pack.root) {
			visitParent(pack.path, parentDirDepthLimit);
		}
		visitIncludes(pack);
	}

	function visitParent(path:String, limit:Int) {
		while (limit > 0) {
			path = Path.join([path, ".."]);
			if (path.length < 2) {
				return;
			}
			var found = visit(path);
			if (found != null) {
				return;
			}
			--limit;
		}
	}

	function visitIncludes(pack:PackageData) {
		if (pack.include != null) {
			for (include in pack.include) {
				var includePath = Path.join([pack.path, include]);
				if (FileUtil.dirExists(includePath)) {
					var child = visit(includePath);
					if (child == null) {
						child = initPackage(includePath, {});
					}
					pack.addChild(child);
				}
			}
		}
	}

	public function addToHxml(hxml:Hxml) {
		addNodeToHxml(hxml, root);
	}

	function addNodeToHxml(hxml:Hxml, pack:PackageData) {
		if (pack != null) {
			// TODO: haxe scripts
			var makePath = Path.join([pack.path, "make"]);
			if (FileUtil.dirExists(makePath)) {
				hxml.classPath.push(makePath);
				MakeLog.debug('-CP $makePath');
			}
			for (lib in pack.libraries.keys()) {
				installDep(hxml, lib, pack.libraries.get(lib));
			}
		}
		for (child in pack._children) {
			addNodeToHxml(hxml, child);
		}
	}

	public function include(pack:PackageData, map:Map<String, String>) {
		if (pack != null) {
			var makePath = Path.join([pack.path, "make"]);
			if (FileUtil.dirExists(makePath)) {
				map.set(makePath, "");
			}
		}
		for (child in pack._children) {
			include(child, map);
		}
	}

	function installDep(hxml:Hxml, lib:String, ver:String) {
		var foundLibPackage = findByName(root, lib);
		if (foundLibPackage != null) {
			Haxelib.dev(lib, foundLibPackage.path);
		}
		else {
			Haxelib.install(lib);
		}

		var libPath = Haxelib.libPath(lib);
		var data = createPackage(libPath);
		if (data != null && data.makeplugin != null) {
			if (data.makeplugin.src != null) {
				for (pluginSrc in data.makeplugin.src) {
					var mkplug = Path.join([libPath, pluginSrc]);
					hxml.classPath.push(mkplug);
					MakeLog.info('-CP $mkplug');
				}
			}
			if (data.makeplugin.lib != null) {
				for (pluginLib in data.makeplugin.lib.keys()) {
					installDep(hxml, pluginLib, data.makeplugin.lib.get(pluginLib));
				}
			}
		}
		else {
			hxml.libraries.push(lib);
			MakeLog.debug('-LIB $lib');
		}
	}

	function findByName(pack:PackageData, name:String):PackageData {
		if (pack != null && pack.name == name) {
			return pack;
		}
		for (child in pack._children) {
			var found = findByName(child, name);
			if (found != null) {
				return found;
			}
		}
		return null;
	}

	function searchConfig(path:String):Array<PackageData> {
		var configs:Array<PackageData> = [];
		for (configFile in configFiles) {
			var configPath = Path.join([path, configFile]);
			if (FileUtil.fileExists(configPath)) {
				try {
					var file = File.getContent(configPath);
					var jsonString = new JSMin(file).output;
					try {
						var data = Json.parse(jsonString);
						configs.push(data);
					}
					catch (e:Dynamic) {
						MakeLog.error(jsonString);
					}
				}
			}
		}
//		for (dir in scanForFolders) {
//			var dirPath = Path.join([path, dir]);
//			if (FileUtil.dirExists(dirPath)) {
//				configs.push({});
//				break;
//			}
//		}
		return configs;
	}

	function mergeConfigs(configs:Array<PackageData>):PackageData {
		return configs.length > 0 ? configs[0] : null;
	}

	function createPackage(path:String):PackageData {
		return initPackage(path, mergeConfigs(searchConfig(path)));
	}

	public static function initPackage(path:String, data:PackageData) {
		if (data != null) {
			if (data.path != null) {
				data.path = Path.join([path, data.path]);
			}
			else {
				data.path = path;
			}

			if (data.name == null) {
				data.name = data.path.split("/").pop();
			}

			if (data.external != null) {
				for (ext in data.external) {
					initPackage(data.path, ext);
				}
			}

			data._children = [];
		}
		return data;
	}
}
