package hxmake.test;

import hxmake.utils.Haxe;
import hxmake.utils.Haxelib;
import hxmake.cli.Platform;
import hxmake.utils.Haxelib;
import hxmake.cli.CL;
import haxe.io.Path;

/*
TODO:
- Travis:
    js
    flash
    lua (mac / linux)

- AppVeyor:
    cpp (very big output)
    lua (how to install)
    php (php command, PATH, check RefreshEnv command)
    js
    flash

- SauceLabs

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
        if(!Haxelib.install(testLib)) {
            return false;
        }

        for (target in targets) {
            if(!runTargetScript(target)) {
                return false;
            }
        }
        return true;
    }

    function runTargetScript(target:String) {
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
        return true;
    }

    function prepareToolsToCompile(target:String) {
        switch(target) {
            case "cpp":
                if(CL.platform.isLinux) {
                    return CiTools.installPackage('gcc-multilib') &&
                        CiTools.installPackage('g++-multilib');
                }
            case "cs":
                if(Sys.command("mono", ["--version"]) != 0) {
                    if(CL.platform.isLinux) {
                        return CiTools.installPackage('mono-devel') &&
                            CiTools.installPackage('mono-mcs');
                    }
                    else if(CL.platform.isMac) {
                        return CiTools.installPackage('mono');
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
                    if(CL.platform.isWindows) {
                        return CiTools.installPackage("php");
                    }
                    else {
                        return CiTools.installPackage("php5");
                    }
                }
            case "python":
                if(!CL.platform.isWindows) {
                    if(Sys.command("python3", ["--version"]) != 0) {
                        return CiTools.installPackage("python3");
                    }
                }
            case "lua":
                if(CL.platform.isWindows) {
                    // TODO:
                }
                else {
                    if(Sys.command("lua", ["-v"]) != 0) {
                        if(CL.platform.isLinux) {
                            if(!CiTools.installPackage("luarocks")) {
                                return false;
                            }
                        }
                        else if(CL.platform.isMac) {
                            if(!CiTools.installPackage("lua")) {
                                return false;
                            }
                        }
                    }

                    if(Sys.command("luarocks", ["install", "lrexlib-pcre"]) != 0) {
                        return false;
                    }

                }
            default:
        }
        return true;
    }

    function prepareEvnLibs(target:String) {
        var compilerLibrary:String = switch(target) {
            case "cpp":
                "hxcpp";
            case "java":
                "hxjava";
            case "cs":
                "hxcs";
            default:
                null;
        }
        return compilerLibrary != null ? Haxelib.install(compilerLibrary, {always: true}) : true;
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
            "-main", main,
            "-dce", "std"
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

        return Haxe.exec(args);
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
                if(CL.platform.isWindows) {
                    cmd = "C:\\Python35-x64\\python.exe";
                }
                else {
                    cmd = "python3";
                }
                args = [Path.join([outPath, "test.py"])];
            case "php":
                cmd = "php";
                args = [Path.join([outPath, "test-php", "index.php"])];
            case "lua":
                cmd = "lua";
                args = [Path.join([outPath, "test.lua"])];
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




}