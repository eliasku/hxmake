package hxmake.haxelib;

import hxmake.haxelib.HaxelibInfo.HaxelibInfo;
import hxmake.haxelib.HaxelibInfo.VcsInfo;
import hxmake.haxelib.HaxelibInfo.VcsType;
import hxmake.utils.CachedHaxelib;
import hxmake.utils.Haxelib;

using StringTools;

class HaxelibDependencies extends Task {
	public static inline var HAXELIB_PREFIX:String = "haxelib:";
	public static inline var HAXELIB_GIT_PREFIX:String = "haxelib:git:";
	public static inline var HAXELIB_HG_PREFIX:String = "haxelib:hg:";

	public function new() {}

	override public function run() {
		if (module.parent == null) {
			var dependencies = collectHaxelibDependencies(module.getSubModules(true, false));
			installHaxelibDependencies(dependencies);
		}
	}

	function collectHaxelibDependencies(modules:Array<Module>):Map<String, HaxelibInfo> {
		var dependencies:Map<String, HaxelibInfo> = new Map();
		for (module in modules) {
			var moduleDependencies:Map<String, String> = Module.getAllDependenciesFromConfig(module.config);
			for (library in moduleDependencies.keys()) {
				var sections:Array<String> = moduleDependencies[library].split(";");
				var libraryInfo:HaxelibInfo = extractHaxelibInformation(library, sections, module.name);
				if (libraryInfo != null) {
					var existLibrary:HaxelibInfo = dependencies.get(library);
					if (existLibrary == null) {
						dependencies.set(library, libraryInfo);
					} else if (!libraryInfo.compareTo(existLibrary)) {
						project.logger.warning(module.name + " has conflict dependency " + libraryInfo + " with " + existLibrary + ". Previous is left.");
					} else {
						// Do nothing.
					}
				}
			}
		}
		return dependencies;
	}

	function installHaxelibDependencies(dependencies:Map<String, HaxelibInfo>) {
		for (library in dependencies.iterator()) {
			if (CachedHaxelib.checkInstalled(library.name, library.isGlobal) && library.version == null) {
				Haxelib.updateLib(library);
			} else {
				Haxelib.installLib(library);
			}
		}
	}

	function extractHaxelibInformation(lib:String, sections:Array<String>, moduleName:String):HaxelibInfo {
		var version:String = (sections != null && sections.length > 0) ? sections[0] : null;
		if (version == null || version == "") {
			return null;
		}

		if (version == "haxelib") {
			return new HaxelibInfo(lib); // TODO: Probably need add global detecting here.
		}

		var isGlobal:Bool = sections.indexOf("global") != -1;

		if (version.startsWith(HAXELIB_GIT_PREFIX) || version.startsWith(HAXELIB_HG_PREFIX)) {
			var vcsType:VcsType;
			var vcsInfoString:String;
			if (version.startsWith(HAXELIB_GIT_PREFIX)) {
				vcsType = VcsType.GIT;
				vcsInfoString = version.substring(HAXELIB_GIT_PREFIX.length);
			} else {
				vcsType = VcsType.Mercurial;
				vcsInfoString = version.substring(HAXELIB_HG_PREFIX.length);
			}

			var vcsInfoSplit:Array<String> = vcsInfoString.split("#");
			var argsCount:Int = vcsInfoSplit.length;
			if (argsCount == 0) {
				fail(moduleName + ": VCS information expected for library " + lib + ".");
				return null;
			}

			var url:String = vcsInfoSplit[0];
			var branch:String = null;
			var subDir:String = null;
			var version:String = null;

			if (argsCount > 1) {
				branch = vcsInfoSplit[1];
			}
			if (argsCount > 2) {
				subDir = vcsInfoSplit[2];
			}
			if (argsCount > 3) {
				version = vcsInfoSplit[3];
			}

			return new HaxelibInfo(lib, version, isGlobal, new VcsInfo(vcsType, url, branch, subDir));
		}

		if (version.startsWith(HAXELIB_PREFIX)) {
			var versionName:String = version.substring(HAXELIB_PREFIX.length);
			if (versionName.endsWith(".git")) {
				project.logger.warning(moduleName + '(Library = ${lib}). Don\'t use haxelib: for git repositories. Deprecated. Use ${HAXELIB_GIT_PREFIX}{url}#[{branch}]#[{subDir}]#[{version}]');
				return new HaxelibInfo(lib, null, isGlobal, new VcsInfo(VcsType.GIT, versionName));
			}
			return new HaxelibInfo(lib, versionName, isGlobal);
		}

		return null;
	}
}
