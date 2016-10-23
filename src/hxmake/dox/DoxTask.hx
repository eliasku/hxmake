package hxmake.dox;

import hxmake.utils.Hxml.DceMode;
import hxmake.test.RunTask;
import hxmake.utils.HaxeTarget;
import hxmake.test.HaxeTask;

class DoxTask extends Task {

	public var classPath:Array<String> = [];
	public var topLevelPackage:Null<String>;
	public var output:String;

	public function new() {}

	override public function configure() {
		if(!module.isActive) {
			return;
		}

		var haxe = new HaxeTask();
		haxe.hxml.classPath = classPath;
		haxe.hxml.debug = true;
		haxe.hxml.defines = ["dox"];

		var cps = [];
		for(cp in classPath) {
			cps.push('"$cp"');
		}
		var cpListString = cps.join(", ");
		haxe.hxml.macros = ['haxe.macro.Compiler.include("", true, [], [$cpListString])'];
		haxe.hxml.xml = 'bin/${module.name}.xml';
		haxe.hxml.output = 'bin/none.js';
		haxe.hxml.target = HaxeTarget.Js;
		haxe.hxml.noOutput = true;
		haxe.hxml.dce = DceMode.DceNo;

		prepend(haxe);

		var generate = new RunTask();
		generate.command = "haxelib";
		generate.arguments = ["run", "dox", "-i", 'bin/${module.name}.xml', "-o", output];
		if(topLevelPackage != null) {
			generate.arguments.push("--toplevel-package");
			generate.arguments.push(topLevelPackage);
		}

		prepend(generate);

	}

	override public function run() {
		if(!module.isActive) {
			return;
		}
	}
}
