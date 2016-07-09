package hxmake.test;

import hxmake.utils.Hxml;
import hxmake.utils.Haxe;
import hxmake.utils.Haxelib;
import hxmake.cli.Platform;
import hxmake.utils.Haxelib;
import hxmake.cli.CL;
import haxe.io.Path;


using hxmake.utils.HaxeTargetTools;

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

class LegacyTestTask extends Task {

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

        for(target in targets) {
            var compileTest = new TestTask();
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

    function build(target:String, run:Bool) {
        var hxml = new Hxml();
        hxml.libraries = libs.concat([testLib]);
        hxml.classPath.push(classPath);
        hxml.dce = DceMode.Std;
        hxml.main = main;
        hxml.target = target.parseHaxeTarget(target);
        hxml.output = hxml.target.buildOutput(Path.join([outPath, "test"]));

        if(!Haxe.compile(hxml)) {
            return false;
        }

        if(!run || hxml.output == null) {
            return true;
        }

        return runTarget(target, hxml);
    }

    function runTarget(target:String, hxml:Hxml):Bool {
        var cmd:String = null;
        var args:Array<String> = [];
        var bin:String = hxml.bin();
        switch(hxml.target) {
            case Interp:
                // already runned
                return true;
            case Neko:
                cmd = "neko";
                args = [bin];
            case Swf:
                cmd = "open";
                args = [bin];
            case Js:
                // TODO: branch;
                //if(target == "node") {
                cmd = "node";
                args = [hxml.bin()];
            case Cpp:
                cmd = hxml.bin();
            case Python:
                if(CL.platform.isWindows) {
                    cmd = "C:\\Python35-x64\\python.exe";
                }
                else {
                    cmd = "python3";
                }
                args = [hxml.bin()];
            case Php:
                cmd = "php";
                args = [hxml.bin()];
            case Lua:
                cmd = "lua";
                args = [hxml.bin()];
            case Cs:
                if(CL.platform.isWindows) {
                    cmd = hxml.bin();
                }
                else {
                    cmd = "mono";
                    args = [hxml.bin()];
                }
            case Java:
                cmd = "java";
                args = ["-jar", hxml.bin()];

            case Hl:
                throw "Target " + target + " is not supported yet";
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