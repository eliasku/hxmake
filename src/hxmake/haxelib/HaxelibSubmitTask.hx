package hxmake.haxelib;

import hxmake.utils.Haxelib;
import hxmake.cli.CL;

class HaxelibSubmitTask extends Task {

    public function new() {
        description = "Submit haxe library package";
    }

    override public function run() {
        var ext:HaxelibExt = module.get("haxelib", HaxelibExt);
        CL.workingDir.with(module.path, function() {
            Haxelib.submit(module.name + ".zip");
        });
    }
}