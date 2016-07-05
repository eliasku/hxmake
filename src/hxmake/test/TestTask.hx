package hxmake.test;

import hxmake.utils.Haxelib;
import hxmake.cli.CL;
import haxe.io.Path;

class TestTask extends Task {

    public var main:String = "TestAll";
    public var classPath:String = "test";
    public var libs:Array<String> = [];
    public var testLib:String = "utest";
    public var targets:Array<String> = ["neko"];
    public var outPath:String = "bin";

    public function new() {
        description = "Build and run tests";
    }

    override public function configure() {
        var customTargets:Array<String> = [];
        for(arg in module.project.args) {
            if(arg.indexOf("-test=") == 0) {
                customTargets.push(arg.substr("-test=".length));
            }
        }
        if(customTargets.length > 0) {
            targets = customTargets;
        }
    }

    override public function run() {
        CL.workingDir.push(module.path);
        runScript();
        CL.workingDir.pop();
    }

    function runScript() {
        if(!prepareTestLib()) {
            return;
        }

        for (target in targets) {
            Sys.println("TARGET: " + target);
            if(!prepareEvnLibs(target)) {
                return;
            }
            if(!build(target)) {
                return;
            }
            if(!runTarget(target)) {
                return;
            }
        }
    }

    function prepareTestLib() {
        if(Haxelib.checkInstalled(testLib)) {
           return true;
        }
        return Sys.command("haxelib", ["install", testLib]) == 0;
    }

    function prepareEvnLibs(target:String) {
        var envLib:String = null;
        switch(target) {
            case "cpp":
                envLib = "hxcpp";
            case "java":
                envLib = "hxjava";
            case "cs":
                envLib = "hxcs";
            default:
        }
        if(envLib != null) {
            if(Haxelib.checkInstalled(envLib)) {
                return true;
            }
            return Sys.command("haxelib", ["install", envLib]) == 0;
        }
        return true;
    }

    function build(target:String) {
        var allLibs = libs.concat([testLib]);
        var args = [];
        for (lib in allLibs) {
            args.push("-lib");
            args.push(lib);
        }
        args = args.concat([
            "-cp", classPath,
            "-main", main
        ]);

        switch(target) {
            case "neko":
                args = args.concat([
                    "-neko", Path.join([outPath, "test.n"])
                ]);
            case "flash" | "as3" | "swf":
                args = args.concat([
                    "-swf", Path.join([outPath, "test.swf"])
                ]);
            case "js" | "node":
                args = args.concat([
                    "-js", Path.join([outPath, "test.js"])
                ]);
            case "cpp":
                args = args.concat([
                    "-cpp", Path.join([outPath, "test-cpp"])
                ]);
            case "java":
                args = args.concat([
                    "-java", Path.join([outPath, "test-java"])
                ]);
            case "cs":
                args = args.concat([
                    "-cs", Path.join([outPath, "test-cs"])
                ]);
            case "php":
                args = args.concat([
                    "-php", Path.join([outPath, "test-php"])
                ]);
            case "python":
                args = args.concat([
                    "-python", Path.join([outPath, "test.py"])
                ]);
            case "lua":
                args = args.concat([
                    "-lua", Path.join([outPath, "test.lua"])
                ]);
            case "hl":
                args = args.concat([
                    "-hl", Path.join([outPath, "test.c"])
                ]);
            default:
                throw "Unknown target: " + target;
        }

        return Sys.command("haxe", args) == 0;
    }

    function runTarget(target:String) {
        var cmd:String = null;
        var args:Array<String> = [];
        switch(target) {
            case "neko":
                cmd = "neko";
                args = [Path.join([outPath, "test.n"])];
            case "flash" | "as3" | "swf":
                cmd = "open";
                args = [Path.join([outPath, "test.swf"])];
            case "js" | "node":
                cmd = "node";
                args = [Path.join([outPath, "test.js"])];
            case "cpp":
                cmd = Path.join([".", outPath, "test-cpp", "TestAll"]);
            case "hl":
                throw "target " + target + " is not supported yet";
            case "python":
                //cmd = "python";
                //args = [Path.join([outPath, "test.py"])];
            case "php":
                cmd = "php";
                args = [Path.join([outPath, "test-php", "index.php"])];
            case "lua":
                //cmd = "lua";
                //args = [Path.join([outPath, "test.lua"])];
            case "cs":
                cmd = "mono";
                //args = [Path.join([outPath, "test.lua"])];
            case "java":
                cmd = "java";
                args = ["-jar", Path.join([outPath, "test-java", "TestAll.jar"])];
            default:
                throw "Unknown target: " + target;
        }
        return cmd == null || Sys.command(cmd, args) == 0;
    }
}