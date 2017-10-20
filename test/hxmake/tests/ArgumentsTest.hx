package hxmake.tests;

import hxmake.core.Arguments;
import utest.Assert;

class ArgumentsTest {

	public function new() {}

	public function testArguments() {
		var arguments = new Arguments([
			"test",
			"-singleKey=123",
			"-arrayKey=1", "-arrayKey=2", "-arrayKey=3",
			"-flag",
			"-flagDoubled", "-flagDoubled"
		]);

		Assert.contains("test", arguments.tasks);
		Assert.equals(1, arguments.tasks.length);
		Assert.isFalse(arguments.hasProperty("test"));
		Assert.isNull(arguments.property("test"));

		Assert.equals("123", arguments.propertyValues("-arrayKey").join(""));
		Assert.equals("1,2,3", arguments.property("-arrayKey"));
		Assert.equals("1|2|3", arguments.property("-arrayKey", "|"));
		Assert.isTrue(arguments.hasProperty("-arrayKey"));

		Assert.equals("123", arguments.property("-singleKey"));
		Assert.isTrue(arguments.hasProperty("-singleKey"));

		Assert.isNull(arguments.property("-noKey"));
		Assert.isFalse(arguments.hasProperty("-noKey"));

		Assert.equals("", arguments.property("-flag"));
		Assert.isTrue(arguments.hasProperty("-flag"));

		Assert.equals(",", arguments.property("-flagDoubled"));
		Assert.isTrue(arguments.hasProperty("-flagDoubled"));

		Assert.same({
			"-singleKey": "123",
			"-arrayKey": "1.2.3",
			"-flag": "",
			"-flagDoubled": "."
		}, arguments.propertiesToDynamic("."));
	}
}
