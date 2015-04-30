module denj.graphics.renderer;

import denj.graphics.common;
import denj.graphics.errorchecking;
import denj.graphics.shaders;
import denj.graphics.buffers;

import denj.math;
import denj.system.window;
import denj.utility.general;
import denj.utility.log;

import std.traits;

import derelict.sdl2.sdl;

private {
	__gshared bool hasInited = false;
	__gshared Renderer thisIsHackyAndShouldBeRemovedASAP = null;
}

struct GLContextSettings{
	uint major;
	uint minor;
	// compatibility
	bool debugContext = false;
	bool doubleBuffer = true;
}

class Renderer {
	enum DefaultContextSettings = GLContextSettings(3, 2);

	private {
		SDL_GLContext sdlGLContext;
		uint glstate;

		Window window;
		ShaderProgram boundShader;
		// Bound buffers
	}

	this(Window win, GLContextSettings glsettings = DefaultContextSettings){
		thisIsHackyAndShouldBeRemovedASAP = this;
		window = win;

		SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, glsettings.major);
		SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, glsettings.minor);
		SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, glsettings.doubleBuffer?1:0);
		SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
		SDL_GL_SetAttribute(SDL_GL_CONTEXT_FLAGS, 
			glsettings.debugContext?SDL_GL_CONTEXT_DEBUG_FLAG:0);

		scope(failure) SDL_GL_DeleteContext(sdlGLContext);
		sdlGLContext = SDL_GL_CreateContext(window.GetSDLWindow());

		if(!sdlGLContext) "GL context creation failed".Except;

		if(!hasInited){
			DerelictGL3.load();
			DerelictGL3.reload(); // required to get access to gl4 functions
			hasInited = true;
		}

		cgl!glGenVertexArrays(1, &glstate);
		cgl!glBindVertexArray(glstate);

		MakeCurrent();
		InitGLDebugging();
	}

	~this(){
		if(sdlGLContext) SDL_GL_DeleteContext(sdlGLContext);
	}

	void MakeCurrent(){
		SDL_GL_MakeCurrent(window.GetSDLWindow(), sdlGLContext);
	}

	void Swap(){
		SDL_GL_SwapWindow(window.GetSDLWindow());
	}

	// Binds values/buffers to attributes
	// Handles the enabling/disabling of vertex attrib arrays
	void SetAttribute(T)(int attr, T valorbuf){
		static if(isBuffer!T){
			// TODO: Add code path for glVertexAttribIPointer for integer types
			// TODO: Add optional stride if buffer base type is struct

			valorbuf.Bind();
			static if(__traits(isScalar, T.BaseType)){
				cgl!glVertexAttribPointer(attr, valorbuf.elements, GetGLType!(T.BaseType), GL_FALSE, 0, null);
			}else static if(isVec!(T.BaseType)){
				cgl!glVertexAttribPointer(attr, valorbuf.elements, GetGLType!(T.BaseType.BaseType), GL_FALSE, 0, null);
			}else{
				static assert(0, "Buffer of type "~T.stringof~" not able to be bound to attributes");
			}

			EnableAttributeArray(attr);
		}else{
			// WARNING: GetGLMangle doesn't handle byte and short types yet because uniforms don't use 'em
			enum mangle = GetGLMangle!T;

			static if(isVec!T){
				mixin("cgl!glVertexAttrib"~mangle~"v(attr, valorbuf.data.ptr);");
			}else static if(isMat!T){
				static assert(0, "Matrices cannot be bound to attributes");

			}else if(__traits(isScalar, T.BaseType)){
				mixin("cgl!glVertexAttrib"~mangle~"(attr, valorbuf);");
			}else{
				static assert(0, "Type "~T.stringof~" not able to be bound to attributes");
			}

			DisableAttributeArray(attr);
		}
	}

	// Calls glDraw(Arrays|Elements)[Instanced] based on bound buffers
	void Draw(){

	}

	void EnableAttributeArray(uint attr){
		cgl!glEnableVertexAttribArray(attr);
	}
	void DisableAttributeArray(uint attr){
		cgl!glDisableVertexAttribArray(attr);
	}
}