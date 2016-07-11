package hxmake.test.flash;

import sys.FileSystem;
import haxe.Http;
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import hxmake.cli.Platform;
import hxmake.cli.CL;

class InstallFlashPlayer extends Task {

    var _fpUrl:String;
    var _fpTrust:String;
    var _mmCfg:String;

    public function new() {}

    override public function run() {
        var fpPath = "flash";
        var fpExeName = switch(CL.platform) {
            case Platform.LINUX: "flashplayerdebugger";
            case Platform.MAC: "Flash Player Debugger.app";
            case Platform.WINDOWS: "flashplayer.exe";
            case _: throw "unknown platform";
        }
        if(!FileSystem.exists(Path.join([fpPath, fpExeName]))) {
            if(!FileSystem.exists(fpPath)) {
                FileSystem.createDirectory(fpPath);
            }
            switch (CL.platform) {
                case Platform.LINUX:
                    // Download and unzip flash player
                    if (Sys.command("wget", [_fpUrl]) != 0) {
                        throw "failed to download flash player";
                    }
                    if (Sys.command("tar", ["-xf", FileSystem.absolutePath(Path.withoutDirectory(_fpUrl)), "-C", FileSystem.absolutePath(fpPath)]) != 0) {
                        throw "failed to extract flash player";
                    }
                    Sys.command("ls", [fpPath]);
                case Platform.MAC:
                // brew cask failing on travis :(
//                    if (Sys.command("brew", ["install", "caskroom/cask/brew-cask"]) != 0) {
//                        throw "failed to brew install caskroom/cask/brew-cask";
//                    }
//                    if (Sys.command("brew", ["cask", "install", "flash-player-debugger", '--appdir=$fpPath']) != 0) {
//                        throw "failed to install flash-player-debugger";
//                    }
                    var fpDmg = '${Path.withoutDirectory(_fpUrl)}';
                    var dmgName = 'Flash\\ Player';
                    download(_fpUrl, FileSystem.absolutePath(fpDmg));
                    if(Sys.command('sudo hdiutil attach ${FileSystem.absolutePath(fpDmg)} -quiet') != 0) {
                        fail('cannot mount $fpDmg');
                    }
                    if(Sys.command('cp -r /Volumes/Flash\\ Player/Flash\\ Player.app ${FileSystem.absolutePath(fpPath)}/Flash\\ Player\\ Debugger.app') != 0) {
                        fail("cannot copy");
                    }
                    if(Sys.command('sudo hdiutil detach /Volumes/$dmgName') != 0) {
                        fail('cannot unmount /Volumes/$dmgName');
                    }
                case Platform.WINDOWS:
                    // Download flash player
                    download(_fpUrl, '$fpPath\\flashplayer.exe');
                case _:
                    throw "unsupported system";
            }
        }

        File.saveContent(_mmCfg, "ErrorReportingEnable=1\nTraceOutputFileEnable=1");

        try {
            // Add the current directory as trusted, so exit() can be used
            if(!FileSystem.exists(_fpTrust)) {
                FileSystem.createDirectory(_fpTrust);
            }
            File.saveContent(Path.join([_fpTrust, "test.cfg"]), Sys.getCwd());
        }
        catch(e:Dynamic) {
            // TODO: message
            Sys.println('WARNING: Cannot add current directory to trusted locations');
        }
    }

    override public function configure() {
        _fpUrl = getFpDownload();
        _fpTrust = getFpTrust();
        _mmCfg = getMmCfg();
    }

// https://www.adobe.com/support/flashplayer/downloads.html
    static function getFpDownload():String {
        return switch(CL.platform) {
            case Platform.LINUX:
                "https://fpdownload.macromedia.com/pub/flashplayer/updaters/11/flashplayer_11_sa_debug.i386.tar.gz";
            case Platform.MAC:
                "http://fpdownload.macromedia.com/pub/flashplayer/updaters/21/flashplayer_21_sa_debug.dmg";
            case Platform.WINDOWS:
                "http://fpdownload.macromedia.com/pub/flashplayer/updaters/21/flashplayer_21_sa_debug.exe";
            case _:
                throw "unsupported system";
        }
    }

    // https://helpx.adobe.com/flash-player/kb/configure-debugger-version-flash-player.html
    static function getMmCfg():String {
        return switch(CL.platform) {
            case Platform.LINUX:
                Path.join([Sys.getEnv("HOME"), "mm.cfg"]);
            case Platform.MAC:
                //"/Library/Application Support/Macromedia/mm.cfg";
                Path.join([Sys.getEnv("HOME"), "mm.cfg"]);
            case Platform.WINDOWS:
                Path.join([Sys.getEnv("HOMEDRIVE") + Sys.getEnv("HOMEPATH"), "mm.cfg"]);
            case _:
                throw "unsupported system";
        }
    }

    // http://help.adobe.com/en_US/ActionScript/3.0_ProgrammingAS3/WS5b3ccc516d4fbf351e63e3d118a9b90204-7c95.html
    static function getFpTrust():String {
        return switch (CL.platform) {
            case Platform.LINUX:
                Path.join([Sys.getEnv("HOME"), ".macromedia/Flash_Player/#Security/FlashPlayerTrust"]);
            case Platform.MAC:
                "/Library/Application Support/Macromedia/FlashPlayerTrust";
            case Platform.WINDOWS:
                Path.join([Sys.getEnv("SYSTEMROOT"), "system32", "Macromed", "Flash", "FlashPlayerTrust"]);
            case _:
                throw "unsupported system";
        }
    }

    static function download(url:String, saveAs:String) {
        Sys.println('Downloading $url to $saveAs...');
        var http = new Http(url);
        http.onError = function(e) {
            throw e;
        };
        http.customRequest(false, File.write(saveAs));
    }
}
