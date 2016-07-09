package hxmake.test;

class RunTask extends Task {

    public var command:String;
    public var arguments:Array<String> = [];

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
        Sys.println('> $command ${arguments.join(" ")}');
        var exitCode = Sys.command(command, arguments);
        if(exitCode != 0) {
            fail('$command exit with non-zero code: $exitCode');
        }
    }
}
