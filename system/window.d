module denj.system.window;

pragma(lib, "DerelictSDL2");
pragma(lib, "DerelictUtil");
pragma(lib, "dl");

import std.string : toStringz;
import denj.system.common;
import denj.utility;

import derelict.util.exception;

//// Hook call order ////
//
//	[Window.FrameBegin]
//		[Event processing]
//		SDLHooks
//		FrameBegin
// 
//	[...]
//
//	[Window.FrameEnd]
//		FrameEnd
//

struct Window {
	enum AllEvents = SDL_LASTEVENT + 1;

	static private {
		SDL_Window* sdlWindow = null;
		int width, height;

		bool isOpen = false;

		void delegate(SDL_Event*) [SDL_EventType] eventHooks;
		void delegate() [] frameBeginHooks;
		void delegate() [] frameEndHooks;
	}

	static void Init(int _width, int _height, string title){
		width = _width;
		height = _height;

		scope(failure) {
			SDL_DestroyWindow(sdlWindow);
			sdlWindow = null;
		}

		sdlWindow = SDL_CreateWindow(title.toStringz, 
			SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
			width, height,
			SDL_WINDOW_OPENGL);

		if(!sdlWindow){
			"Window creation failed".Except;
		}

		isOpen = true;
	}

	static this(){
		DerelictSDL2.missingSymbolCallback = (string) => ShouldThrow.No;
		DerelictSDL2.load();

		scope(failure) SDL_Quit();
		if(SDL_Init(SDL_INIT_EVERYTHING) < 0){
			"SDL init failed".Except;
		}
	}
	static ~this(){
		SDL_Quit();
	}

	static void HookSDL(SDL_EventType evtType, void delegate(SDL_Event*) hook){
		eventHooks[evtType] = hook;
	}

	static void HookFrameBegin(void delegate() hook){
		frameBeginHooks ~= hook;
	}
	static void HookFrameEnd(void delegate() hook){
		frameEndHooks ~= hook;
	}

	static void FrameBegin(){
		if(!isOpen) return;

		// Event processing
		SDL_Event e;
		auto ghook = AllEvents in eventHooks;

		while(SDL_PollEvent(&e)){
			if(e.type == SDL_QUIT
			|| e.type == SDL_WINDOWEVENT && e.window.event == SDL_WINDOWEVENT_CLOSE){
				Close();
				return;
			}

			// SDL hooks
			if(ghook) (*ghook)(&e);

			auto hook = e.type in eventHooks;
			if(hook) (*hook)(&e);
		}
		
		// Hook dispatch
		foreach(h; frameBeginHooks){
			h();
		}
	}
	static void FrameEnd(){
		if(!isOpen) return;

		foreach(h; frameEndHooks){
			h();
		}
	}

	static void Swap(){
		SDL_GL_SwapWindow(sdlWindow);
	}

	static void Close(){
		isOpen = false;

		if(sdlWindow) SDL_DestroyWindow(sdlWindow);
		sdlWindow = null;
	}

	static bool IsOpen(){
		return isOpen;
	}

	static int GetWidth(){
		return width;
	}
	static int GetHeight(){
		return height;
	}

	static SDL_Window* GetSDLWindow(){
		return sdlWindow;
	}
}