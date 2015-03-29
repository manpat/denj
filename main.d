module main;

import derelict.sdl2.sdl;
import derelict.opengl3.gl3;
import denj.utility.general;
import denj.utility.log;
import denj.math.vector;
import denj.system.window;

import std.string;

version = WindowTest;

struct Thing {
	int a = 123;
	float b = 456.7;
	string c = "89 10";
	vec2 d = vec2(0.707, 1.52);
}

void main(){
	try{
		ClearLog();
		Log("Denj test", " lelel ", 123);
		Log("Denj test", " lelel ", Thing());
		LogF("Format format %s format %s", Thing(555, 666.0, "abc"), "blah");

		version(WindowTest) RunWindowTest();
		
	}catch(Exception e){
		LogF("%s:%s: error: %s", e.file, e.line, e.msg);
	}

	Log("Finished");
	FlushLog();
}

void RunWindowTest(){
	Log("Running window test");

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

	window2.MakeMain();
	window.Close();

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
		SDL_Delay(10);
	}
}