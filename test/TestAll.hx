package ;

import hxmake.tests.ArgumentsTest;
import hxmake.tests.RunEmptyProjectTest;
import utest.Runner;
import utest.ui.Report;

class TestAll {

	public static function addTests(runner:Runner) {
		runner.addCase(new ArgumentsTest());
		runner.addCase(new RunEmptyProjectTest());
	}

	public static function main() {
		var runner = new Runner();
		addTests(runner);
		run(runner);
	}

	static function run(runner:Runner) {
		Report.create(runner);
		runner.run();
	}
}