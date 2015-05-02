module tests.window;

import derelict.sdl2.sdl;

import denj.utility;
import denj.system.window;
import denj.graphics.common;
import denj.graphics.renderer;

import std.string;

void WindowTests(){
	auto window = new Window(800, 600, "Thing");
	auto window2 = new Window(200, 200, "Thing2");
	auto window3 = new Window(200, 200, "Thing3");

	auto renderer = new Renderer(window);
	auto renderer3 = new Renderer(window3);

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
		renderer.MakeCurrent();
		glClearColor(1f, 0f, 0f, 1f);
		glClear(GL_COLOR_BUFFER_BIT);
		renderer.Swap();

		renderer3.MakeCurrent();
		glClearColor(0f, 0f, 1f, 1f);
		glClear(GL_COLOR_BUFFER_BIT);
		renderer3.Swap();

		Window.UpdateAll();
		SDL_Delay(50);
	}
}