package;

import utest.Runner;
import utest.ui.Report;

class TestMain {
	public static function main() {
		var r = new Runner();
		TestCollector.addAllCases(r);
		Report.create(r);
		r.run();
	}
}
