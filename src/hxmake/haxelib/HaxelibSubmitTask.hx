package hxmake.haxelib;

import hxmake.utils.Haxelib;
import hxmake.cli.CL;

class HaxelibSubmitTask extends Task {

    public function new() {
        description = "Submit haxe library package";
    }

    override public function run() {
        var ext:HaxelibExt = module.get("haxelib", HaxelibExt);

        if(ext.config.license == null || ext.config.license.length == 0) {
            Sys.println('Haxelib: missing license value');
            return;
        }

        if(ext.config.releasenote == null || ext.config.releasenote.length == 0) {
            Sys.println('Haxelib: missing releasenote value');
            return;
        }

        CL.workingDir.with(module.path, function() {
            Haxelib.submit(module.name + ".zip");
        });
    }
}