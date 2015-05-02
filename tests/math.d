module tests.math;

import denj.utility;
import denj.math;

void MathTests(){
	auto a = vec4(1, 0, 1, 0);
	auto b = vec4(1, 1, 0.4, 0);

	LogF("%s + %s = %s", a, b, a + b);
	Log("TODO: write more math");
}