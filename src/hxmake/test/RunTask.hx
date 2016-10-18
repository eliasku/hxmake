package hxmake.test;

import hxmake.cli.CL;

class RunTask extends Task {

    public var command:String;
    public var arguments:Array<String> = [];
    public var retryUntilZero:Int = 0;
    public var failNonZero:Bool = true;
    public var exitCode:Int = 0;

    public function new(?command:String, ?arguments:Array<String>) {
        set(command, arguments);
    }

    public function set(command:String, ?arguments:Array<String>) {
        this.command = command;
        this.arguments = arguments != null ? arguments : [];
    }

    override public function run() {
        if(command == null || command.length == 0) {
            // nothing to run
            return;
        }

        execute();

        if(exitCode != 0 && failNonZero) {
            failExitCode();
        }
    }

    function execute() {
        exitCode = -1;
        var i = retryUntilZero + 1;

        while(i > 0 && exitCode != 0) {
            exitCode = CL.command(command, arguments);
            --i;
        }
    }

    public function failExitCode() {
        fail('$command exit with non-zero code: $exitCode');
    }
}
