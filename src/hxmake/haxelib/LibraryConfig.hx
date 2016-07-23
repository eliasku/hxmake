package hxmake.haxelib;

class LibraryConfig {

    // by default module-name is used
    public var name:String;
    public var description:String = "";
    public var version:String = "0.0.1";
    public var contributors:Array<String> = [];
    public var license:String;
    public var url:String;
    public var tags:Array<String> = [];
    public var classPath:String;
    public var dependencies:Map<String, String> = new Map();

    public function new() {}

    public function toDynamic():Dynamic {
        var data:Dynamic = {
            name: name,
            description: description,
            version: version
        };

        if(contributors.length > 0) {
            data.contributors = contributors;
        }

        if(license != null) {
            data.license = license;
        }

        if(url != null) {
            data.url = url;
        }

        if(tags.length > 0) {
            data.tags = tags;
        }

        if(classPath != null) {
            data.classPath = classPath;
        }

        for(k in dependencies.keys()) {
            data.dependencies = dependencies;
            break;
        }

        return data;
    }
}
