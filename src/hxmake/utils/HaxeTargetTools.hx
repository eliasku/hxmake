package hxmake.utils;

import hxmake.utils.HaxeTarget;

@:final
class HaxeTargetTools {

    @:pure
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

    public static function parseHaxeTarget(target:String):Null<HaxeTarget> {
        return
            switch(target) {
                case "cpp": Cpp;
                case "php": Php;
                case "js", "node", "html5": Js;
                case "neko", "n": Neko;
                case "flash", "as3", "swf": Swf;
                case "java": Java;
                case "cs": Cs;
                case "lua": Lua;
                case "hl", "c": Hl;
                case "python": Python;
                case "interp", "haxe": Interp;
                default:
                    throw 'Unknown haxe target: $target';
            }
    }

    @:pure
    static public function buildOutput(target:HaxeTarget, name:String):String {
        var postfix:Null<String> =
            switch(target) {
                case Interp: null;
                case Neko: ".n";
                case Swf: ".swf";
                case Js: ".js";
                case Python: ".py";
                case Lua: ".lua";
                case Hl: ".hl";
                case Cpp: "-cpp";
                case Cs: "-cs";
                case Java: "-java";
                case Php: "-php";
            }
        return postfix != null ? (name + postfix) : null;
    }
}
