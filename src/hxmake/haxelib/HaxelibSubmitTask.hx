package hxmake.haxelib;

import hxmake.cli.MakeLog;
import hxmake.utils.Haxelib;

class HaxelibSubmitTask extends Task {

    public function new() {
        description = "Submit haxe library package";
    }

    override public function run() {
        var ext:HaxelibExt = module.get("haxelib", HaxelibExt);

        if(ext == null || !module.isActive) {
            return;
        }

        if(ext.config.license == null || ext.config.license.length == 0) {
            MakeLog.info('Haxelib: missing license value');
            return;
        }

        if(ext.config.releasenote == null || ext.config.releasenote.length == 0) {
            MakeLog.info('Haxelib: missing releasenote value');
            return;
        }

        var zipName = module.name + ".zip";
        Haxelib.submit(zipName);
    }
}