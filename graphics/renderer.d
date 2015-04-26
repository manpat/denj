module denj.graphics.renderer;

import denj.graphics.common;
import denj.system.window;
import denj.utility.general;
import denj.utility.log;

import derelict.sdl2.sdl;

private {
	__gshared bool hasInited = false;
	__gshared Renderer thisIsHackyAndShouldBeRemovedASAP = null;
}

struct GLContextSettings{
	uint major;
	uint minor;
}

class Renderer {
	enum DefaultContextSettings = GLContextSettings(3, 2);

	private {
		SDL_GLContext sdlGLContext;
		Window window;
	}

	this(Window win, GLContextSettings glsettings = DefaultContextSettings){
		thisIsHackyAndShouldBeRemovedASAP = this;
		window = win;

		SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, glsettings.major);
		SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, glsettings.minor);
		SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
		SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);

		scope(failure) SDL_GL_DeleteContext(sdlGLContext);
		sdlGLContext = SDL_GL_CreateContext(window.GetSDLWindow());

		if(!sdlGLContext) "GL context creation failed".Except;

		if(!hasInited){
			DerelictGL3.load();
			DerelictGL3.reload();
			hasInited = true;
		}

		MakeCurrent();
	}

	~this(){
		if(sdlGLContext) SDL_GL_DeleteContext(sdlGLContext);
	}

	void MakeCurrent(){
		SDL_GL_MakeCurrent(window.GetSDLWindow(), sdlGLContext);
	}

	void Draw(){
		SDL_GL_SwapWindow(window.GetSDLWindow());
	}
}