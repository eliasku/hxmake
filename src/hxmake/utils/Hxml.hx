package hxmake.utils;

import haxe.io.Path;
import hxmake.cli.CL;

using StringTools;
using hxmake.utils.HaxeTargetTools;

class Hxml {

    public var libraries:Array<String> = [];
    public var classPath:Array<String> = [];
    public var main:String;
    public var defines:Array<String> = [];
    public var macros:Array<String> = [];
    public var commands:Array<String> = [];

    public var target:Null<HaxeTarget> = null;
    public var output:Null<String> = null;

    public var debug:Bool = false;
    public var showTimes:Bool = false;
    public var showMacroTimes:Bool = false;

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

        result.push("-main");
        result.push(main);

        for(def in defines) {
            result.push("-D");
            result.push(def);
        }

        if(showTimes) {
            result.push("--times");
        }

        if(showMacroTimes) {
            result.push("-D");
            result.push("macro-times");
        }

        if(debug) {
            result.push("-debug");
            switch(target) {
                case Swf: result = result.concat(["-D", "fdb"]);
                case _:
            }
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

        if(dce != null) {
            result.push("-dce");
            result.push(
                switch(dce) {
                    case No: "no";
                    case Std: "std";
                    case Full: "full";
                }
            );
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
                if(CL.platform.isWindows) {
                    Path.join([output, '$main.exe']).replace("/", "\\");
                }
                else {
                    Path.join([".", output, main]);
                }
            case Php:
                Path.join([output, "index.php"]);
            case Cs:
                var exeFile = Path.join([output, 'bin/$main.exe']);
                if(CL.platform.isWindows) {
                    exeFile = exeFile.replace("/", "\\");
                }
                exeFile;
            case Java:
                Path.join([output, '$main.jar']);
        }
    }
}

enum DceMode {
    No;
    Std;
    Full;
}
