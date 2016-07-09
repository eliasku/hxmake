package hxmake.test;

import hxmake.utils.HaxeTarget;
import hxmake.cli.CL;
import haxe.io.Path;
import hxmake.utils.Hxml;

using hxmake.utils.HaxeTargetTools;

class TestTask extends Task {

    inline static var OPTION_OVERRIDE_TEST_TARGET:String = "--override-test-target=";

    public var targets:Array<String> = [];
    public var libraries:Array<String> = [];
    public var testLibrary:String = "utest";
    public var classPath:String = "test";
    public var main:String = "TestAll";
    public var outputDir:String = "bin";
    public var outputName:String = "test";
    public var runTests:Bool = true;

    var _compileTasks:Array<HaxeTask>;
    var _runTasks:Array<RunTask>;

    public function new() {}

    override public function configure() {
        targets = overrideTargets();
        _compileTasks = compileTasks();
        _runTasks = runTasks();

        prepend(setupTestLibrary());

        for(ct in _compileTasks) {
            prepend(ct);
        }

        for(rt in _runTasks) {
            prepend(rt);
        }
    }

    @:pure
    function overrideTargets() {
        var customTargets:Array<String> = [];
        for(arg in module.project.args) {
            if(arg.indexOf(OPTION_OVERRIDE_TEST_TARGET) == 0) {
                customTargets.push(arg.substr(OPTION_OVERRIDE_TEST_TARGET.length));
            }
        }
        return customTargets.length > 0 ? customTargets : targets;
    }

    @:pure
    function setupTestLibrary():SetupTask {
        var task = new SetupTask();
        task.name = "setup-test-library";
        task.libraries = [testLibrary];
        return task;
    }

    @:pure
    function compileTasks() {
        var result:Array<HaxeTask> = [];
        for(target in targets) {
            var compileTask = new HaxeTask();
            compileTask.name = "compile-test-" + target;
            compileTask.targetName = target;
            compileTask.hxml.libraries = libraries.concat([testLibrary]);
            compileTask.hxml.classPath.push(classPath);
            compileTask.hxml.dce = DceMode.Std;
            compileTask.hxml.main = main;
            compileTask.hxml.target = target.parseHaxeTarget();
            compileTask.hxml.output = compileTask.hxml.target.buildOutput(Path.join([outputDir, outputName]));
            compileTask.prepend(compileTask.createSetupTask());
            result.push(compileTask);
        }
        return result;
    }

    @:pure
    function runTasks():Array<RunTask> {
        var result:Array<RunTask> = [];
        if(runTests) {
            for(ct in _compileTasks) {
                var runTask = runTask(ct.targetName, ct.hxml.target, ct.hxml.bin());
                runTask.prepend(setupRun(ct.targetName));
                result.push(runTask);
            }
        }
        return result;
    }

    @:pure
    function setupRun(target:String):SetupTask {
        var setup = new SetupTask();
        setup.name = 'setup-run-test-$target';
        switch(target) {
            case "php":
                if(Sys.command("php", ["--version"]) != 0) {
                    setup.packages.push(CL.platform.isWindows ? "php" : "php5");
                }
            case "python":
                if(!CL.platform.isWindows) {
                    if(Sys.command("python3", ["--version"]) != 0) {
                        setup.packages.push("python3");
                    }
                }
            case "lua":
                if(CL.platform.isWindows) {
                    // TODO:
                }
                else {
                    if(Sys.command("lua", ["-v"]) != 0) {
                        if(CL.platform.isLinux) {
                            setup.packages.push("luarocks");
                        }
                        else if(CL.platform.isMac) {
                            setup.packages.push("lua");
                        }
                    }

                    setup.then(new RunTask("luarocks", ["install", "lrexlib-pcre"]));
                }
            default:
        }
        return setup;
    }

    @:pure
    public function runTask(target:String, haxeTarget:HaxeTarget, bin:String):RunTask {
        var runTask:RunTask = new RunTask();
        runTask.name = 'run-test-$target';
        switch(haxeTarget) {
            case Interp:
                // already runned
            case Neko:
                runTask.set("neko", [bin]);
            case Swf:
                // TODO:
                runTask.set("open", [bin]);
            case Js:
                // TODO: branch;
                if(target == "node") {
                    runTask.set("node", [bin]);
                }
                else {
                    // TODO:
                }
            case Cpp:
                runTask.set(bin);
            case Python:
                runTask.set("python3", [bin]);
                if(CL.platform.isWindows) {
                    // TODO:
                    runTask.command = "C:\\Python35-x64\\python.exe";
                }
            case Php:
                runTask.set("php", [bin]);
            case Lua:
                runTask.set("lua", [bin]);
            case Cs:
                if(!CL.platform.isWindows) {
                    runTask.set("mono", [bin]);
                }
                else {
                    runTask.set(bin);
                }
            case Java:
                runTask.set("java", ["-jar", bin]);
            case Hl:
                fail('Target $target is not supported yet');
        }
        return runTask;
    }

    override public function run() {}
}
