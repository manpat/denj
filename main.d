module main;

import derelict.sdl2.sdl;
import derelict.opengl3.gl3;
import denj.utility.log;
import denj.math.vector;
import denj.system.window;

import std.string;

struct Thing {
	int a = 123;
	float b = 456.7;
	string c = "89 10";
	vec2 d = vec2(0.707, 1.52);
}

void main(){
	ClearLog();
	Log("Denj test", " lelel ", 123);
	Log("Denj test", " lelel ", Thing());
	LogF("Format format %s format %s", Thing(555, 666.0, "abc"), "blah");

	Log("Creating window");

	auto window = new Window(800, 600, "Thing");
	auto window2 = new Window(200, 200, "Thing2");
	auto window3 = new Window(200, 200, "Thing3");
	SDL_EventState(SDL_DROPFILE, SDL_ENABLE);

	window.HookSDL(SDL_KEYDOWN, (SDL_Event* e){
		Log("window1 ", e.key.keysym.sym, " is escape? ", e.key.keysym.sym == SDLK_ESCAPE);
		if(e.key.keysym.sym == SDLK_ESCAPE)
			window.Close();
	});
	window2.HookSDL(SDL_KEYDOWN, (SDL_Event* e){
		Log("window2 ", e.key.keysym.sym, " is escape? ", e.key.keysym.sym == SDLK_ESCAPE);
		if(e.key.keysym.sym == SDLK_ESCAPE)
			window2.Close();
	});

	window3.HookSDL(SDL_KEYDOWN, (SDL_Event* e){
		Log("window3 ", e.key.keysym.sym, " is escape? ", e.key.keysym.sym == SDLK_ESCAPE);
		if(e.key.keysym.sym == SDLK_ESCAPE)
			window3.Close();
	});

	window2.HookSDL(SDL_DROPFILE, (SDL_Event* e){
		Log("File drop: ", e.drop.file.fromStringz);
		SDL_free(e.drop.file);
		FlushLog();
	});

	while(window.IsOpen()){
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