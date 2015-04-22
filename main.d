module main;

import derelict.sdl2.sdl;
import derelict.opengl3.gl3;
import denj.system.window;
import denj.system.input;
import denj.graphics;
import denj.utility;
import denj.math;
import std.math;

import std.string;

// version = TestLog;
// version = TestMath;
// version = TestWindow;
// version = TestInput;
version = TestGraphics;
// version = RunScratch;

void main(){
	ClearLog();

	version(TestLog) RunTest!LogTests();
	version(TestMath) RunTest!MathTests();
	version(TestWindow) RunTest!WindowTests();
	version(TestInput) RunTest!InputTests();
	version(TestGraphics) RunTest!GraphicsTests();
	version(RunScratch) RunTest!Scratch();

	Log("Finished");
	FlushLog();
}

void RunTest(alias test)(){
	Log("Running " ~ test.stringof);
	try{
		test();
	}catch(Exception e){
		LogF("%s:%s: error: in "~test.stringof~": %s", e.file, e.line, e.msg);
	}
	Log(test.stringof ~ " done");
	Log();
}

void LogTests(){
	struct Thing {
		int a = 123;
		float b = 456.7;
		string c = "89 10";
		vec2 d = vec2(0.707, 1.52);
	}

	Log("Denj test", " lelel ", 123);
	Log("Denj test", " lelel ", Thing());
	LogF("Format format %s format %s", Thing(555, 666.0, "abc"), "blah");
}

void MathTests(){
	auto a = vec4(1, 0, 1, 0);
	auto b = vec4(1, 1, 0.4, 0);

	LogF("%s + %s = %s", a, b, a + b);
	Log("TODO: write more math");
}

void WindowTests(){
	auto window = new Window(800, 600, "Thing");
	auto window2 = new Window(200, 200, "Thing2");
	auto window3 = new Window(200, 200, "Thing3");
	SDL_EventState(SDL_DROPFILE, SDL_ENABLE);

	Window.HookAllSDL(SDL_KEYDOWN, (SDL_Event* e){
		Log("window ", e.key.keysym.sym, " is escape? ", e.key.keysym.sym == SDLK_ESCAPE);
		if(e.key.keysym.sym == SDLK_ESCAPE)
			Window.GetMain().Close();

		if(e.key.keysym.sym == SDLK_q)
			Window.GetWindow(e.key.windowID).Close();
	});

	window2.HookSDL(SDL_DROPFILE, (SDL_Event* e){
		Log("File drop: ", e.drop.file.fromStringz);
		SDL_free(e.drop.file);
		FlushLog();
	});

	window3.MakeMain();
	window2.Close();

	while(Window.IsValid()){
		window.MakeCurrent();
		glClearColor(1f, 0f, 0f, 1f);
		glClear(GL_COLOR_BUFFER_BIT);
		window.Swap();

		window2.MakeCurrent();
		glClearColor(0f, 1f, 0f, 1f);
		glClear(GL_COLOR_BUFFER_BIT);
		window2.Swap();

		window3.MakeCurrent();
		glClearColor(0f, 0f, 1f, 1f);
		glClear(GL_COLOR_BUFFER_BIT);
		window3.Swap();

		Window.UpdateAll();
		SDL_Delay(50);
	}
}

void InputTests(){
	auto window = new Window(200, 200, "InputTest");
	auto input = new Input(window);

	while(Window.IsValid()){
		window.Update();
		if(input.KeyPressed(SDLK_ESCAPE)) window.Close();

		if(input.KeyPressed(SDLK_a)){
			glClearColor(1,1,0,1);
		}else if(input.KeyReleased(SDLK_a)){
			glClearColor(0,1,1,1);
		}else if(input.KeyDown(SDLK_s)){
			glClearColor(1,0,1,1);
		}else{
			glClearColor(1,1,1,1);
		}

		glClear(GL_COLOR_BUFFER_BIT);

		window.Swap();
		SDL_Delay(50);
	}
}

void GraphicsTests(){
	import std.file;

	auto sh = ShaderProgram.LoadFromMemory(read("shader.shader"));
}

void Scratch(){
	
}