package hxmake.utils;

import hxlog.Log;
import hxmake.cli.CL;
import hxmake.cli.Platform;

@:final
class Haxe {

    static inline var ALIAS:String = "haxe";

    public static function compile(hxml:Hxml):Bool {
        return exec(hxml.options());
    }

    public static function exec(args:Array<String>):Bool {
        return CL.command(ALIAS, args) == 0;
    }

    static inline var HAXE_PATH_ENV:String = "HAXEPATH";
    static inline var HAXE_PATH_WINDOWS:String = "C:\\HaxeToolkit\\haxe\\";
    static inline var HAXE_PATH_OSX:String = "/usr/local/lib/haxe/";

    // TODO: move to HaxeManager class
    // TODO: Linux default haxe-path
    // TODO: try get path from global HAXE_STD_PATH
    // TODO: Haxe executable exists
    public static function path():String {
        var path = Sys.getEnv(HAXE_PATH_ENV);
        if (path != null && path.length > 0) {
            return path;
        }
        Log.warning("Please set HAXEPATH environment variable");
        switch(CL.platform) {

            case Platform.MAC, Platform.LINUX:
                return HAXE_PATH_OSX;

            case Platform.WINDOWS:
                // useful trick from NME tool
                var nekoPath = Sys.executablePath();
                var parts = nekoPath.split("\\");
                if (parts.length > 3 && parts[parts.length - 2] == "neko") {
                    return parts.slice(0, parts.length - 2).join("\\") + "\\haxe\\";
                }
                else {
                    return HAXE_PATH_WINDOWS;
                }

            case _: // unknown
        }
        return "";
    }
}
