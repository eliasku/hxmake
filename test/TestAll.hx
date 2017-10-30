package ;

import hxmake.cli.MakeLog;
import hxmake.tests.ArgumentsTest;
import hxmake.tests.ModuleConnectionTest;
import hxmake.tests.RunEmptyProjectTest;
import hxmake.tests.TaskRunnerTest;
import hxmake.tests.TaskTest;
import utest.Runner;
import utest.ui.Report;

class TestAll {

	public static function addTests(runner:Runner) {
		runner.addCase(new ArgumentsTest());
		runner.addCase(new RunEmptyProjectTest());
		runner.addCase(new ModuleConnectionTest());
		runner.addCase(new TaskTest());
		runner.addCase(new TaskRunnerTest());
	}

	public static function main() {
		MakeLog.logger.setupFilter(false, true);
		var runner = new Runner();
		addTests(runner);
		run(runner);
	}

	static function run(runner:Runner) {
		Report.create(runner);
		runner.run();
	}
}