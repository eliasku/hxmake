package hxmake.test;

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
        var customTargets:Array<String> = null;
        for(arg in module.project.args) {
            if(arg.indexOf("targets=") == 0) {
                customTargets = arg.substr("targets=".length).split(",");
            }
        }
        if(customTargets != null && customTargets.length > 0) {
            targets = customTargets;
        }
    }

    override public function run() {
        CL.workingDir.push(module.path);

        for (target in targets) {
            if(build(target)) {
                runTarget(target);
            }
        }

        CL.workingDir.pop();
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
            case "java" | "cs" | "php" | "python" | "lua" | "hl":
                throw "target " + target + " is not supported yet";
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
            case "java" | "cs" | "php" | "python" | "lua" | "hl":
                throw "target " + target + " is not supported yet";
            default:
                throw "Unknown target: " + target;
        }
        return Sys.command(cmd, args);
    }
}