package hxmake.utils;

using StringTools;

class Hxml {

    public var libraries:Array<String> = [];
    public var classPath:Array<String> = [];
    public var main:String;
    public var defines:Array<String> = [];
    public var macros:Array<String> = [];
    public var commands:Array<String> = [];

    public var target:Null<HaxeTarget> = null;
    public var output:Null<String> = null;

    public var showTimes:Bool = false;
    public var showMacroTimes:Bool = false;

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

        if(target != null) {
            result.push(compileOption(target));
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

    public function setOutputGen(output:String) {
        var postfix:Null<String> =
            switch(target) {
                case Interp: null;
                case Neko: ".n";
                case Swf: ".swf";
                case Js: ".js";
                case Python: ".py";
                case Lua: ".lua";
                case Hl: ".c";
                case Cpp: "-cpp";
                case Cs: "-cs";
                case Java: "-java";
                case Php: "-php";
            }
        this.output = postfix != null ? (output + postfix) : null;
    }

    public static function compileOption(target:HaxeTarget):String {
        return
            switch(target) {
                case Cpp: "-cpp";
                case Php: "-php";
                case Js: "-js";
                case Neko: "-neko";
                case Swf: "-swf";
                case Java: "-java";
                case Cs: "-cs";
                case Lua: "-lua";
                case Hl: "-hl";
                case Python: "-python";
                case Interp: "--interp";
            }
    }

}
