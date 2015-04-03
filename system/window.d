module denj.system.window;

pragma(lib, "DerelictSDL2");
pragma(lib, "DerelictGL3");
pragma(lib, "DerelictUtil");
pragma(lib, "dl");

import std.string : toStringz;
import derelict.sdl2.sdl;
import derelict.opengl3.gl3;
import derelict.util.exception;
import denj.utility.general;
import denj.utility.log;

private {
	__gshared Window[uint] windows;
	__gshared bool hasInited = false;
}

class Window {
	enum AllEvents = SDL_LASTEVENT + 1;

	private {
		SDL_Window* sdlWindow;
		SDL_GLContext sdlGLContext;
		int width, height;

		uint id = 0;
		bool isMaster = false;
		bool isOpen = false;

		void delegate(SDL_Event*) [uint] eventHooks;
		void delegate() [] frameBeginHooks;
		void delegate() [] updateHooks;
	}

	this(int _width, int _height, string title){
		if(!hasInited){
			DerelictSDL2.missingSymbolCallback = (string) => ShouldThrow.No;

			DerelictGL3.load();
			DerelictSDL2.load();

			scope(failure) SDL_Quit();
			if(SDL_Init(SDL_INIT_EVERYTHING) < 0){
				"SDL init failed".Except;
			}

			isMaster = true;
			windows[0] = this;
		}

		SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
		SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 2);
		SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
		SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);

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

		scope(failure) SDL_GL_DeleteContext(sdlGLContext);
		sdlGLContext = SDL_GL_CreateContext(sdlWindow);

		if(!sdlGLContext) "GL context creation failed".Except;

		if(!hasInited){
			DerelictGL3.load();
		}

		hasInited = true;
		isOpen = true;
		id = SDL_GetWindowID(sdlWindow);
		windows[id] = this;
	}

	~this(){
		if(sdlGLContext) SDL_GL_DeleteContext(sdlGLContext);
		if(sdlWindow) SDL_DestroyWindow(sdlWindow);
		if(isMaster) {
			foreach(w; windows){
				w.Close();
			}

			SDL_Quit();
			windows[0] = null;
			hasInited = false;
		}
	}

	static Window GetMain(){
		auto main = 0 in windows;

		return main?*main:null;
	}

	static Window GetWindow(uint id){
		auto win = id in windows;

		return win?*win:null;
	}

	static void UpdateAll(){
		auto main = windows[0];
		main.Update();
		foreach(w; windows.values){
			// Because the main window occurs twice in windows
			if(w.id != main.id){
				w.Update();
			}
		}
	}

	static void HookAllSDL(uint evtType, void delegate(SDL_Event*) hook){
		foreach(i, w; windows){
			if(i != 0){
				w.HookSDL(evtType, hook);
			}
		}
	}

	static bool IsValid(){
		auto main = 0 in windows;

		return main?main.isOpen:false;
	}

	void HookSDL(uint evtType, void delegate(SDL_Event*) hook){
		eventHooks[evtType] = hook;
	}

	void HookUpdate(void delegate() hook){
		updateHooks ~= hook;
	}

	void HookFrameBegin(void delegate() hook){
		frameBeginHooks ~= hook;
	}

	void Update(){
		if(!sdlWindow) return;

		if(!isOpen){
			windows.remove(id);
			if(sdlGLContext) SDL_GL_DeleteContext(sdlGLContext);
			if(sdlWindow) SDL_DestroyWindow(sdlWindow);

			sdlWindow = null;
			sdlGLContext = null;

			return;
		}

		foreach(h; frameBeginHooks){
			h();
		}

		if(isMaster){
			SDL_Event e;
			bool windowSpecific = false;
			uint window = 0;
			while(SDL_PollEvent(&e)){
				switch(e.type){
					case SDL_QUIT:
						Close();
						return;
				
					// Because some events don't
					//	have a windowID
					case SDL_KEYDOWN:
					case SDL_KEYUP:
					case SDL_MOUSEMOTION:
					case SDL_MOUSEBUTTONDOWN:
					case SDL_MOUSEBUTTONUP:
					case SDL_MOUSEWHEEL:
					case SDL_WINDOWEVENT:
						windowSpecific = true;
						window = e.window.windowID;
						break;

					default:
						windowSpecific = false;
				}

				if(windowSpecific){
					// Only dispatch to specific window
					auto w = window in windows;
					if(w){
						w.ProcessEvent(&e);
					}else{
						//Log("Window not found ", window);
						// window was probably closed 
					}
				}else{
					// Dispatch to all
					foreach(w; windows){
						w.ProcessEvent(&e);
					}
				}
			}
		}

		foreach(h; updateHooks){
			h();
		}
	}

	protected void ProcessEvent(SDL_Event* e){
		switch(e.type){
			case SDL_WINDOWEVENT:
				if(e.window.event == SDL_WINDOWEVENT_CLOSE)
					Close();

				break;

			default:
				break;
		}

		auto ghook = AllEvents in eventHooks;
		if(ghook) (*ghook)(e);

		auto hook = e.type in eventHooks;
		if(hook) (*hook)(e);
	}

	void Close(){
		isOpen = false;
	}

	void MakeCurrent(){
		if(sdlWindow)
			SDL_GL_MakeCurrent(sdlWindow, sdlGLContext);
	}

	void Swap(){
		if(sdlWindow)
			SDL_GL_SwapWindow(sdlWindow);
	}

	void MakeMain(){
		auto main = 0 in windows;
		if(main) main.isMaster = false;

		windows[0] = this;
		isMaster = true;
	}

	bool IsOpen(){
		return isOpen;
	}

	bool IsMain(){
		return isMaster;
	}

	uint GetId(){
		return id;
	}
}