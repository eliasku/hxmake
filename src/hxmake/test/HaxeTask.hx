package hxmake.test;

import hxmake.cli.CL;
import hxmake.utils.Haxe;
import hxmake.utils.Hxml;

class HaxeTask extends Task {

    // Meta information for keeping wide target key: mac, win, node, etc...
    public var targetName:String;

    public var hxml(default, null):Hxml = new Hxml();

    public function new() {}

    override public function run() {
        if(!Haxe.compile(hxml)) {
            fail("Compilation failed");
        }
    }

    public function createSetupTask():SetupTask {
        var pct = new SetupTask();
        switch(hxml.target) {
            case Cpp:

                if(CL.platform.isLinux) {
                    pct.packages = pct.packages.concat(['gcc-multilib', 'g++-multilib']);
                }
                pct.libraries.push("hxcpp");
            case Cs:
                if(CL.command("mono", ["--version"]) != 0) {
                    if(CL.platform.isLinux) {
                        pct.packages = pct.packages.concat(['mono-devel', 'mono-mcs']);
                    }
                    else if(CL.platform.isMac) {
                        pct.packages.push('mono');
                    }
                }
                pct.libraries.push("hxcs");
            case Java:
                pct.libraries.push("hxjava");
            default:
        }

        if(targetName == "node" || targetName == "nodejs") {
            pct.libraries.push("hxnodejs");
        }

        return pct;
    }
}
