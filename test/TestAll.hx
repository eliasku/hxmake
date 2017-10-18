package ;

import hxmake.tests.SimpleTest;
import utest.Runner;
import utest.ui.Report;

class TestAll {

	public static function addTests(runner:Runner) {
		runner.addCase(new SimpleTest());
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