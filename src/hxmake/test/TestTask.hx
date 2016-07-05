package hxmake.test;

import hxmake.cli.Platform;
import hxmake.utils.Haxelib;
import hxmake.cli.CL;
import haxe.io.Path;

/*
TODO:
- Travis: js / flash / lua (mac / linux)
- AppVeyor
- SauceLabs for browsers

- Node on travis (now use stock node)
 */

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
        if(!runScript()) {
            throw "Test task failed";
        }
        CL.workingDir.pop();
    }

    function runScript():Bool {
        if(!prepareTestLib()) {
            return false;
        }

        for (target in targets) {
            Sys.println("TARGET: " + target);
            if(!prepareToolsToCompile(target)) {
                return false;
            }
            if(!prepareEvnLibs(target)) {
                return false;
            }
            if(!build(target)) {
                return false;
            }

            if(!prepareToolsToRun(target)) {
                return false;
            }
            if(!runTarget(target)) {
                return false;
            }
        }
        return true;
    }

    function prepareTestLib() {
        if(Haxelib.checkInstalled(testLib)) {
           return true;
        }
        return Sys.command("haxelib", ["install", testLib]) == 0;
    }

    function prepareToolsToCompile(target:String) {
        switch(target) {
            case "cpp":
                if(CL.platform.isLinux) {
                    aptGet('gcc-multilib');
                    aptGet('g++-multilib');
                }
            case "cs":
                if(Sys.command("mono", ["--version"]) != 0) {
                    if(CL.platform.isLinux) {
                        aptGet('mono-devel');
                        aptGet('mono-mcs');
                    }
                    else if(CL.platform.isMac) {
                        aptGet('mono');
                    }
                }
            default:
        }
        return true;
    }

    function prepareToolsToRun(target:String) {
        switch(target) {
            case "php":
                if(Sys.command("php", ["--version"]) != 0) {
                    aptGet("php5");
                }
            case "python":
                if(Sys.command("python3", ["--version"]) != 0) {
                    aptGet("python3");
                }
            default:
        }
        return true;
    }

    function prepareEvnLibs(target:String) {
        switch(target) {
            case "cpp":
                return installLibrary("hxcpp");
            case "java":
                return installLibrary("hxjava");
            case "cs":
                return installLibrary("hxcs");
            default:
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
            case "interp":
                args.push("--interp");
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
            case "interp":
                return true;
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
                var exeFileName = "TestAll";
                if(CL.platform.isWindows) {
                    cmd = Path.join([outPath, "test-cpp", exeFileName + ".exe"]);
                    cmd = StringTools.replace(cmd, "/", "\\");
                }
                else {
                    cmd = Path.join([".", outPath, "test-cpp", exeFileName]);
                }
            case "hl":
                throw "target " + target + " is not supported yet";
            case "python":
                cmd = "python3";
                args = [Path.join([outPath, "test.py"])];
            case "php":
                cmd = "php";
                args = [Path.join([outPath, "test-php", "index.php"])];
            case "lua":
                //cmd = "lua";
                //args = [Path.join([outPath, "test.lua"])];
            case "cs":
                var exeFile = Path.join([outPath, "test-cs", "bin", "TestAll.exe"]);
                if(CL.platform.isWindows) {
                    cmd = StringTools.replace(exeFile, "/", "\\");
                }
                else {
                    cmd = "mono";
                    args = [exeFile];
                }
            case "java":
                cmd = "java";
                args = ["-jar", Path.join([outPath, "test-java", "TestAll.jar"])];
            default:
                throw "Unknown target: " + target;
        }

        if(cmd != null) {
            Sys.println("EXEC: " + cmd + " " + args.join(" "));
        }
        else {
            Sys.println("SKIP runnning for " + target);
        }

        return cmd == null || Sys.command(cmd, args) == 0;
    }

    function installLibrary(library:String) {
        if(Sys.command("haxelib", ["path", library]) != 0) {
            return Sys.command("haxelib", ["install", library, "--always"]) == 0;
        }
        return true;
    }

    function aptGet(pckge:String, ?additionalArgs:Array<String>) {
        var cmd = null;
        var args = [];

        switch(CL.platform) {
            case Platform.LINUX:
                cmd = "sudo";
                args = ["apt-get", "install", "-qq", pckge];
            case Platform.MAC:
                cmd = "brew";
                args = ['install', pckge];
            case x:
                Sys.println('Cannot run apt-get on $x');
                return false;
        }
        if(additionalArgs != null) {
            args = args.concat(additionalArgs);
        }
        return Sys.command(cmd, args) == 0;
    }
}