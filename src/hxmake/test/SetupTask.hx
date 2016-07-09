package hxmake.test;

import hxmake.utils.Haxelib;

class SetupTask extends Task {

    public var packages:Array<String> = [];
    public var libraries:Array<String> = [];

    public function new() {}

    override public function run() {
        for(pack in packages) {
            if(!CiTools.installPackage(pack)) {
                fail('Failed to install package: ${pack}');
            }
        }
        for(lib in libraries) {
            if(!Haxelib.install(lib, {always: true})) {
                fail('Failed to install library: ${lib}');
            }
        }
    }
}
