package hxmake.test;

// todo final
import hxmake.cli.Platform;
import hxmake.cli.CL;

@:final
class CiTools {

    public static function isPackageInstalled(pckge:String) {
        return switch(CL.platform) {
            case Platform.LINUX:
                CL.command("dpkg-query", ["-W", "-f='${Status}'", pckge]) == 0;
            case Platform.MAC:
                // TODO:
                false;
            case Platform.WINDOWS:
                // TODO:
                false;
            default:
                throw "Unknown platform";
        }

    }
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
        return CL.command(cmd, args) == 0;
    }
}
