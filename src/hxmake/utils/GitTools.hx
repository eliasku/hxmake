package hxmake.utils;
import hxmake.cli.CL;
class GitTools {
    /**
        Return recent tag name with commit hash in format:
        {tag name}-{commits count past recent tag}-{eight chars hash of last commit}

        E.g.:
            - If current position in tree referes to tag commit: 2.1.0
            - If current position in tree referes to two commits past tag: 2.1.0-2-g2414721

        @param dropSuffix   Drop last commit hash and commits count past tag
        @param defaultVersionName   Default version name will be used if there is no git repo, or tag can't be retrieved
                                    If null specified - expection will be thrown
    **/
    public static function getCurrentTagVersion(dropSuffix:Bool = false, defaultVersionName:String = null):String {
        var args = ["describe", "--tags"];
        if (dropSuffix) {
            args[args.length] = "--abbrev=0";
        }
        var result = CL.execute("git", args);
        if (result.exitCode != 0) {
            if (defaultVersionName == null) {
                throw 'Can\'t get library version from git.\nExit code: ${result.exitCode}\n${result.stderr}';
            } else {
                return defaultVersionName;
            }
        }
        return StringTools.trim(result.stdout);
    }
}
