package hxmake.utils;

import hxmake.cli.MakeLog;
import hxmake.haxelib.HaxelibInfo.HaxelibInfo;
import hxmake.haxelib.HaxelibInfo.VcsType;
import hxmake.haxelib.HaxelibInfo.VcsInfo;
import hxmake.cli.CL;
import sys.FileSystem;
import haxe.io.Path;
import haxe.io.Input;

using StringTools;

@:final
class Haxelib {

    static inline var ALIAS:String = "haxelib";

    public static function run(library:String, args:Array<String>):Bool {
        return exec([library].concat(args));
    }

    public static function dev(library:String, path:String):Bool {
        return exec(["dev", library, path]);
    }

    public static function git(library:String, url:String, forceGlobal:Bool = false):Bool {
        return vcs(VcsType.GIT, library, url, null, null, null, forceGlobal);
    }

    public static function vcs(vcsType:VcsType, library:String, url:String, branch:String = null, subDir:String = null, version:String = null, forceGlobal:Bool = false):Bool {
        var vcsName:String;
        switch(vcsType) {
            case VcsType.GIT:
                vcsName = "git";
            case VcsType.Mercurial:
                vcsName = "hg";
            case _:
                MakeLog.error("Unsuported vcs type " + vcsType);
                return false;
        }

        var commands:Array<String> = [vcsName, library, url];
        commands.push(branch == null ? "" : branch);
        commands.push(subDir == null ? "" : subDir);
        commands.push(version == null ? "" : version);
        return exec(commands, forceGlobal ? ["--global"] : null);
    }

    public static function updateLib(library:HaxelibInfo):Bool {
        return update(library.name, library.isGlobal);
    }

    public static function update(library:String, forceGlobal:Bool = false):Bool {
        return exec(["update", library], forceGlobal ? ["--global"] : null);
    }

    public static function installLib(library:HaxelibInfo):Bool {
        if (library.vcsInfo != null) {
            var vcsInfo:VcsInfo = library.vcsInfo;
            return vcs(vcsInfo.type, library.name, vcsInfo.url, vcsInfo.branch, vcsInfo.subDir, library.version, library.isGlobal);
        } else {
            return install(library.name, library.version, {global: library.isGlobal});
        }
    }

    public static function install(library:String, ?version:String, ?options:{?always:Bool, ?silent:Bool, ?global:Bool}):Bool {
        if(classPath(library) != null) {
            // already installed
            return true;
        }

        var additionalArguments:Array<String> = [];
        if(options != null) {
            if(options.always == true) {
                additionalArguments.push("--always");
            }
            if(options.global == true) {
                additionalArguments.push("--global");
            }
//            if(options.silent == true) {
//                args.push("--quiet");
//            }
        }

        return exec(["install", withVersion(library, version)], additionalArguments);
    }

    public static function checkInstalled(library:String, forceGlobal:Bool = false):Bool {
        return classPath(library, forceGlobal) != null;
    }

    // Returns library root path (not classpath)
    // TODO: add class path support (make search from haxelib repo path)
    // TODO: support for version
    public static function libPath(library:String, forceGlobal:Bool = false):String {
        return resolveRootPathFromClassPath(classPath(library, forceGlobal));
    }

    public static function resolveRootPathFromClassPath(path:String):String {
        if(path == null) {
            return null;
        }
        // FIXME: temproary workaround
        // TODO: resolve class-path from haxelib.json
        if(Path.removeTrailingSlashes(path).endsWith("src")) {
            return Path.normalize(Path.join([path, ".."]));
        }
        return path;
    }

    public static function classPath(library:String, forceGlobal:Bool = false):String {
        var optLines = path(library, forceGlobal);
        for (opt in optLines) {
            if (opt.length > 0 && opt.charAt(0) != "-" && FileSystem.exists(opt)) {
                return opt;
            }
        }
        return null;
    }

    public static function path(library:String, forceGlobal:Bool = false):Array<String> {
        var args = [];
        if(forceGlobal) {
            args.unshift("--global");
        }
        return CL.execute(ALIAS, ["path", library].concat(args)).readLines();
    }

    public static function submit(zipPath:String):Bool {
        if(!FileSystem.exists(zipPath)) {
            MakeLog.error('$zipPath not found');
            return false;
        }
        return exec(["submit", zipPath]);
    }

    public static function exec(args:Array<String>, ?additionalArguments:Array<String>):Bool {
        if(additionalArguments != null) {
            args = args.concat(additionalArguments);
        }
        return CL.command(ALIAS, args) == 0;
    }

    static function withVersion(library:String, ?version:String):String {
        if (version != null && version.length > 0) {
            return library + ":" + version;
        }
        return library;
    }

    static function readLines(input:Input):Array<String> {
        var result:Array<String> = [];
        try {
            while(true) {
                result.push(input.readLine());
            }
        }
        catch(e:Dynamic) {}
        return result;
    }


}
