package hxmake.macr;

import hxmake.cli.MakeLog;
import hxmake.utils.Haxelib;
import haxe.Json;
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;

class PluginInclude {
    static var _makeLibraries:Array<String> = [];

    public static function scan(path:String) {
        var pluginsPath = Path.join([path, "plugins.json"]);
        if(FileSystem.exists(pluginsPath)) {
            try {
                var content = File.getContent(pluginsPath);
                var data = Json.parse(content);
                for(field in Reflect.fields(data)) {
                    include(field, Reflect.field(data, field));
                }
            }
            catch(e:Dynamic) {}
        }
    }

    public static function include(name:String, path:String):Bool {
        if(_makeLibraries.indexOf(name) >= 0) {
            return true;
        }

        // TODO: relative path, git, accurate haxelib
        var lp = Haxelib.libPath(name, true);
        if(lp == null) {
            Haxelib.install(name);
            lp = Haxelib.libPath(name, true);
        }
        if(lp == null) {
            return false;
        }
        var cp = Path.join([lp, "makeplugin"]);
        if(FileSystem.exists(cp)) {
            MakeLog.info('Make Plugin: $name @ $cp');
            CompileTime.addMakePath(cp);
        }

        _makeLibraries.push(name);
        return true;
    }
}