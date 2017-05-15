package hxmake.haxelib;

import haxe.Json;
class HaxelibInfo {
    public var name:String;
    public var vcsInfo:VcsInfo;
    public var isGlobal:Bool;
    public var version:String;

    public function new(name:String, version:String = null, isGlobal:Bool = false, vcsInfo:VcsInfo = null) {
        this.name = name;
        this.version = version;
        this.isGlobal = isGlobal;
        this.vcsInfo = vcsInfo;
    }

    public function toString():String {
        return Json.stringify({
            name: name,
            isGlobal: isGlobal,
            version: version,
            vcsInfo: vcsInfo
        });
    }

    public function compareTo(other:HaxelibInfo):Bool {
        if (other == null) {
            return false;
        }
        if (other == this) {
            return true;
        }
        if (other.name != this.name) {
            return false;
        }
        if (other.isGlobal != this.isGlobal) {
            return false;
        }
        if (other.version != this.version) {
            return false;
        }

        if (this.vcsInfo == null && other.vcsInfo == null) {
            return true;
        } else if (this.vcsInfo != null) {
            return this.vcsInfo.compareTo(other.vcsInfo);
        } else {
            return false;
        }
    }
}

@:enum
abstract VcsType(String) {
    var GIT = "git";
    var Mercurial = "hg";
}

class VcsInfo {
    public var type:VcsType;
    public var url:String;
    public var branch:String;
    public var subDir:String;

    public function new(type:VcsType, url:String, branch:String = null, subDir:String = null) {
        this.type = type;
        this.url = url;
        this.branch = branch;
        this.subDir = subDir;
    }

    public function toString():String {
        return Json.stringify({
            type: type,
            url: url,
            branch: branch,
            subDir: subDir
        });
    }

    public function compareTo(other:VcsInfo):Bool {
        if (other == null) {
            return false;
        }

        if (this == other) {
            return true;
        }

        if (this.type != other.type) {
            return false;
        }

        if (this.url != other.url) {
            return false;
        }

        if (this.branch != other.branch) {
            return false;
        }

        if (this.subDir != other.subDir) {
            return false;
        }

        return true;
    }
}
