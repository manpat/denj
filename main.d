module main;

import denj.utility;

import tests.utility;
import tests.containers;
import tests.math;
import tests.window;
import tests.input;
import tests.graphics;
import tests.entities;

void main(){
	//RunTest!LogTests();
	//RunTest!MathTests();
	//RunTest!ContainerTests();
	//RunTest!WindowTests();
	//RunTest!InputTests();
	//RunTest!GraphicsTests();
	RunTest!EntityTests();
	//RunTest!Scratch();

	Log("Finished");
}

void RunTest(alias test)(){
	Log("Running " ~ test.stringof);
	try{
		test();
	}catch(Exception e){
		LogF("%s:%s: error: in %s: %s", e.file, e.line, test.stringof, e.msg);
		throw e;
	}
	Log(test.stringof ~ " done");
	Log();
}

void Scratch(){
}