package hxmake.test;

import hxmake.utils.Haxelib;

class SetupTask extends Task {

    public var packages:Array<String> = [];
    public var libraries:Array<String> = [];
    public var librariesFromGit:Array<String> = [];

    public function new() {}

    override public function run() {
        for(pack in packages) {
            if(CiTools.isPackageInstalled(pack)) {
                Sys.println('$pack is already installed');
                continue;
            }
            if(!CiTools.installPackage(pack)) {
                fail('Failed to install package: ${pack}');
            }
        }
        for(git in librariesFromGit) {
            var args = git.split(";");
            if(!Haxelib.checkInstalled(args[0])) {
                if(!Haxelib.git(args[0], args[1])) {
                    fail('Failed to install library from git: ${args[0]} @ ${args[1]}');
                }
            }
        }
        for(lib in libraries) {
            if(!Haxelib.install(lib, {always: true})) {
                fail('Failed to install library: ${lib}');
            }
        }
    }
}
