module tests.utility;

import denj.utility;
import denj.math;

private struct Thing {
	int a = 123;
	float b = 456.7;
	string c = "89 10";
	vec2 d = vec2(0.707, 1.52);
}

void LogTests(){
	Log("Denj test", " lelel ", 123);
	Log("Denj test", " lelel ", Thing());
	LogF("Format format %s format %s", Thing(555, 666.0, "abc"), "blah");
}

// Timer tests