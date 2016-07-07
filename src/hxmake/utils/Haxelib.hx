package hxmake.utils;

import haxe.io.Path;
import sys.FileSystem;
import haxe.io.Input;
import sys.io.Process;

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
        return exec(["git", library, url], forceGlobal ? ["--global"] : null);
    }

    public static function update(library:String, forceGlobal:Bool = false):Bool {
        return exec(["update", library], forceGlobal ? ["--global"] : null);
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
        var cp = classPath(library, forceGlobal);
        if(cp == null) {
            return null;
        }
        // FIXME: temproary workaround
        if(Path.removeTrailingSlashes(cp).endsWith("src")) {
            return Path.normalize(Path.join([cp, ".."]));
        }
        return cp;
    }

    public static function classPath(library:String, forceGlobal:Bool = false):String {
        var optLines = path(library, forceGlobal);
        if(optLines == null) {
            return null;
        }
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
        var opts:Array<String> = null;
        var proc = new Process(ALIAS, ["path", library].concat(args));
        if(proc.exitCode() == 0) {
            opts = readLines(proc.stdout);
        }
        proc.close();
        return opts;
    }

    static function withVersion(library:String, ?version:String):String {
        if (version != null && version.length > 0) {
            return library + ":" + version;
        }
        return library;
    }

    public static function exec(args:Array<String>, ?additionalArguments:Array<String>):Bool {
        if(additionalArguments != null) {
            args = args.concat(additionalArguments);
        }
        Sys.println('> $ALIAS ${args.join(" ")}');
        return Sys.command(ALIAS, args) == 0;
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
