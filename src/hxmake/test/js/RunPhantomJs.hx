package hxmake.test.js;

import hxmake.macr.CompileTime;
import sys.io.File;
import haxe.io.Path;
import haxe.Template;

class RunPhantomJs extends RunTask {

    public var jsPath:String;

    public function new(jsPath:String) {
        super();
        this.jsPath = jsPath;
    }

    override public function run() {
        var jsDir = Path.directory(jsPath);
        var htmlPath = Path.join([jsDir, "phantomjs.html"]);
        var html = genFile(CompileTime.readFile("../resources/phantomjs/phantomjs.html"), {
            jsFile: Path.withoutDirectory(jsPath)
        });
        File.saveContent(htmlPath, html);

        var runnerPath = Path.join([jsDir, "phantomjs.js"]);
        var runnerJs = genFile(CompileTime.readFile("../resources/phantomjs/phantomjs.js"), {
            html: htmlPath
        });
        File.saveContent(runnerPath, runnerJs);

        command = "phantomjs";
        arguments = [runnerPath];

        super.run();
    }

    static function genFile(tpl:String, context:Dynamic) {
        var tmpl = new Template(tpl);
        return tmpl.execute(context);
    }
}
