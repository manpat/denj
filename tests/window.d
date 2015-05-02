module tests.window;

import derelict.sdl2.sdl;

import denj.utility;
import denj.system.window;
import denj.graphics.common;
import denj.graphics.renderer;

import std.string;

void WindowTests(){
	Window.Init(800, 600, "Thing");
	Renderer.Init();

	// SDL_EventState(SDL_DROPFILE, SDL_ENABLE);

	Window.HookSDL(SDL_KEYDOWN, (SDL_Event* e){
		Log("window ", e.key.keysym.sym, " is escape? ", e.key.keysym.sym == SDLK_ESCAPE);
		if(e.key.keysym.sym == SDLK_ESCAPE)
			Window.Close();
	});

	while(Window.IsOpen()){
		Window.FrameBegin();

		glClearColor(1f, 0f, 0f, 1f);
		glClear(GL_COLOR_BUFFER_BIT);

		Window.Swap();
		Window.FrameEnd();
		SDL_Delay(50);
	}
}