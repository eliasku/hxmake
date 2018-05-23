package hxmake.utils;

import haxe.io.Path;
import hxmake.cli.CL;

using StringTools;
using hxmake.utils.HaxeTargetTools;

class Hxml {

    public var libraries:Array<String> = [];
    public var classPath:Array<String> = [];

    public var main:Null<String>;
    public var defines:Array<String> = [];
    public var macros:Array<String> = [];
    public var commands:Array<String> = [];
    public var resources:Map<String, String> = new Map();

    public var flags:Array<String> = [];
    public var flagArguments:Array<String> = [];

    public var target:Null<HaxeTarget> = null;
    public var output:Null<String> = null;

    public var debug:Bool = false;
    public var showTimes:Bool = false;
    public var showMacroTimes:Bool = false;
    public var noTraces:Bool = false;

    // adds --no-output
    public var noOutput:Bool = false;

    // generate -xml $value
    public var xml:Null<String> = null;

    public var dce:Null<DceMode> = null;

    public function new() {}

    public function options():Array<String> {
        var result = [];
        for(lib in libraries) {
            result.push("-lib");
            result.push(lib);
        }
        for(cp in classPath) {
            result.push("-cp");
            result.push(cp);
        }

        if(main != null) {
            result.push("-main");
            result.push(main);
        }

        for(def in defines) {
            result.push("-D");
            result.push(def);
        }

        if(dce != null) {
            result.push("-dce");
            result.push(
                switch(dce) {
                    case DceNo: "no";
                    case DceStd: "std";
                    case DceFull: "full";
                }
            );
        }

        if(showTimes) {
            result.push("--times");
        }

        if(showMacroTimes) {
            result.push("-D");
            result.push("macro-times");
        }

        if(noTraces) {
            result.push("--no-traces");
        }

        if(noOutput) {
            result.push("--no-output");
        }

        if(debug) {
            result.push("-debug");
            switch(target) {
                case Swf: result = result.concat(["-D", "fdb"]);
                case Cpp: result = result.concat(["-D", "HXCPP_DEBUG_LINK"]);
                case _:
            }
        }

        for(i in 0...flags.length) {
            result.push(flags[i]);
            if(flagArguments[i] != null) {
                result.push(flagArguments[i]);
            }
        }

        if(xml != null) {
            result.push("-xml");
            result.push(xml);
        }

        if(target != null) {
            result.push(target.compileOption());
            if(output != null) {
                result.push(output);
            }
        }

        for(m in macros) {
            result.push("--macro");
            result.push(m.replace('"', "'"));
        }

        for(cmd in commands) {
            result.push("-cmd");
            result.push(cmd);
        }

        return result;
    }

    public function bin():Null<String> {
        return switch(target) {
            case Interp:
                null;
            case Neko, Swf, Js, Hl, Python, Lua:
                output;
            case Cpp:
                var executableName = getClassName(main);

                var isStaticLink = defines.indexOf("static_link") >= 0;
                var isAndroid = defines.indexOf("android") >= 0;

                if(isAndroid) {
                    executableName = "lib" + executableName;
                }

                if(debug) {
                    executableName += "-debug";
                }

                if(defines.indexOf("HXCPP_ARMV7") >= 0) {
                    executableName += "-v7";
                }
                else if(defines.indexOf("HXCPP_X86") >= 0) {
                    executableName += "-x86";
                }

                if(isAndroid) {
                    executableName += isStaticLink ? ".a" : ".so";
                }

                if(CL.platform.isWindows) {
                    Path.join([output, '$executableName.exe']).replace("/", "\\");
                }
                else {
                    Path.join([".", output, executableName]);
                }
            case Php:
                Path.join([output, "index.php"]);
            case Cs:
                var executableName = main;
                if(debug) {
                    executableName += "-Debug";
                }
                var exeFile = Path.join([output, 'bin/$executableName.exe']);
                if(CL.platform.isWindows) {
                    exeFile = exeFile.replace("/", "\\");
                }
                exeFile;
            case Java:
                var executableName = main;
                if(debug) {
                    executableName += "-Debug";
                }
                Path.join([output, '$executableName.jar']);
        }
    }

    public function flag(options:String, ?argument:String) {
        flags.push(options);
        flagArguments.push(argument);
    }

    @:pure
    static function getClassName(path:String):String {
        var p = path.split(".");
        return p[p.length - 1];
    }
}

enum DceMode {
    DceNo;
    DceStd;
    DceFull;
}
