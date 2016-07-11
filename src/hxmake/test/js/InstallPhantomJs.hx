package hxmake.test.js;

class InstallPhantomJs extends Task {

    public function new() {}

    override public function run() {
        if(Sys.command("phantomjs", ["-v"]) != 0) {
            CiTools.installPackage("phantomjs");
        }
    }
}
