module denj.graphics.renderer;

pragma(lib, "DerelictGL3");

import denj.graphics.common;
import denj.graphics.errorchecking;
import denj.graphics.shaders;
import denj.graphics.buffers;

import denj.math;
import denj.system.common;
import denj.system.window;
import denj.utility;

import std.traits;

private {
	__gshared bool hasInited = false;
}

struct GLContextSettings{
	uint major;
	uint minor;
	// compatibility
	bool debugContext = false;
	bool doubleBuffer = true;
}

struct Renderer {
	enum DefaultContextSettings = GLContextSettings(3, 2);

	static private {
		SDL_GLContext sdlGLContext;
		uint glstate;

		ShaderProgram boundShader;
		// Bound buffers
	}

	static void Init(GLContextSettings glsettings = DefaultContextSettings){
		SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, glsettings.major);
		SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, glsettings.minor);
		SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, glsettings.doubleBuffer?1:0);
		SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
		SDL_GL_SetAttribute(SDL_GL_CONTEXT_FLAGS, 
			glsettings.debugContext?SDL_GL_CONTEXT_DEBUG_FLAG:0);

		scope(failure) SDL_GL_DeleteContext(sdlGLContext);
		sdlGLContext = SDL_GL_CreateContext(Window.GetSDLWindow());

		if(!sdlGLContext) "GL context creation failed".Except;

		if(!hasInited){
			DerelictGL3.load();
			DerelictGL3.reload(); // required to get access to gl4 functions
			hasInited = true;
		}

		// TODO: replace with extension test
		if(glsettings.major >= 3){
			cgl!glGenVertexArrays(1, &glstate);
			cgl!glBindVertexArray(glstate);

			InitGLDebugging();
		}
	}

	static ~this(){
		if(sdlGLContext) SDL_GL_DeleteContext(sdlGLContext);
	}

	// Binds values/buffers to attributes
	// Handles the enabling/disabling of vertex attrib arrays
	static void SetAttribute(T)(int attr, T valorbuf){
		// TODO: Check if attr exists in bound shader
		static if(isBuffer!T){
			// TODO: Add code path for glVertexAttribIPointer for integer types
			// TODO: Add optional stride if buffer base type is struct

			valorbuf.Bind();
			cgl!glVertexAttribPointer(attr, valorbuf.elements, valorbuf.glBaseType, GL_FALSE, 0, null);

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
	static void Draw(uint drawMode){
		// TODO: Draw instanced
		if(IsBufferBound(BufferType.Index)){
			auto ibo = GetBoundBuffer(BufferType.Index);
			cgl!glDrawElements(drawMode, cast(int) ibo.length, ibo.glBaseType, null);
		}else{
			auto vbo = GetBoundBuffer(BufferType.Array);
			cgl!glDrawArrays(drawMode, 0, cast(int) vbo.length);
		}
	}

	// TODO: Draw range

	// These are called by SetAttribute and probably shouldn't be
	//	called manually
	static void EnableAttributeArray(uint attr){
		cgl!glEnableVertexAttribArray(attr);
	}
	static void DisableAttributeArray(uint attr){
		cgl!glDisableVertexAttribArray(attr);
	}
}