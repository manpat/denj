module tests.window;

import derelict.sdl2.sdl;

import denj.utility;
import denj.system.window;
import denj.graphics.common;
import denj.graphics.renderer;

import std.string;

void WindowTests(){
	auto window = Window(800, 600, "Thing");
	auto renderer = Renderer(window);

	// SDL_EventState(SDL_DROPFILE, SDL_ENABLE);

	window.HookSDL(SDL_KEYDOWN, (SDL_Event* e){
		Log("window ", e.key.keysym.sym, " is escape? ", e.key.keysym.sym == SDLK_ESCAPE);
		if(e.key.keysym.sym == SDLK_ESCAPE)
			window.Close();
	});

	while(window.IsOpen()){
		window.FrameBegin();

		glClearColor(1f, 0f, 0f, 1f);
		glClear(GL_COLOR_BUFFER_BIT);

		window.Swap();
		window.FrameEnd();
		SDL_Delay(50);
	}
}