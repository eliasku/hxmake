package hxmake.haxelib;

class LibraryPackage {

    public static var HIDDEN_FILES(default, null):EReg = ~/\.(svn)|(git)|(DS_Store)|(tmbuild)/;

    public var filters:Array<EReg> = [HIDDEN_FILES];
    public var includes:Array<String> = [];

    public function new() {}
}
