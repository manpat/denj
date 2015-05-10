module tests.math;

import denj.utility;
import denj.math;

void MathTests(){
	VectorTests();
	MatrixTests();
}

private:
void VectorTests(){
	Log("VectorTests");

	auto a = vec4(1, 0, 1, 0);
	auto b = vec4(1, 1, 0.4, 0);

	LogF("%s + %s = %s", a, b, a + b);
	Log();
}

void MatrixTests(){
	Log("MatrixTests");
	auto r90 = mat4.XRotation(PI/2f);
	auto m43 = Matrix!(4, 3).YRotation(PI/2f);

	Log("RX90 \n", r90);
	Log("RX90 R'd 180 \n", r90.RotateX(PI/2f)*r90);
	Log("RX90 R'd 90Y \n", m43 * r90);

	Log();
}