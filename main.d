module main;

import denj.utility;

import tests.utility;
import tests.math;
import tests.window;
import tests.input;
import tests.graphics;

// version = TestLog;
// version = TestMath;
// version = TestWindow;
version = TestInput;
version = TestGraphics;
// version = RunScratch;

void main(){
	version(TestLog) RunTest!LogTests();
	version(TestMath) RunTest!MathTests();
	version(TestWindow) RunTest!WindowTests();
	version(TestInput) RunTest!InputTests();
	version(TestGraphics) RunTest!GraphicsTests();
	version(RunScratch) RunTest!Scratch();

	Log("Finished");
}

void RunTest(alias test)(){
	Log("Running " ~ test.stringof);
	try{
		test();
	}catch(Exception e){
		LogF("%s:%s: error: in "~test.stringof~": %s", e.file, e.line, e.msg);
		throw e;
	}
	Log(test.stringof ~ " done");
	Log();
}

void Scratch(){
	
}