package hxmake.test;

// todo final
import hxmake.utils.Haxelib;
import hxmake.cli.Platform;
import hxmake.cli.CL;

class CiTools {

    public static function installPackage(pckge:String, ?additionalArgs:Array<String>):Bool {
        var cmd = null;
        var args = [];

        switch(CL.platform) {
            case Platform.LINUX:
                cmd = "sudo";
                args = ["apt-get", "install", "-qq", pckge];
            case Platform.MAC:
                cmd = "brew";
                args = ['install', pckge];
            case Platform.WINDOWS:
                cmd = "cinst";
                args = [pckge, '-y'];
            default:
                throw "Unknown platform";
        }
        if(additionalArgs != null) {
            args = args.concat(additionalArgs);
        }
        return Sys.command(cmd, args) == 0;
    }
}
