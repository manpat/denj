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
	// TODO: compatibility
	bool debugContext = false;
	bool doubleBuffer = true;
}

struct Renderer {
	enum DefaultContextSettings = GLContextSettings(3, 2);

	static private {
		SDL_GLContext sdlGLContext;
		uint glstate;

		ShaderProgram boundShader;
		// Attribute -> Buffer map
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
	static void Draw(uint drawMode, uint start = 0, int count = -1){
		// TODO: Check bound attributes instead of bound buffers
		//		Attributes can be set to constants
		if(!IsBufferBound(Buffer.Type.Array)){
			"Tried to draw with no attribute array bound".Except;
		}

		// TODO: Draw instanced
		if(IsBufferBound(Buffer.Type.Index)){
			auto ibo = GetBoundBuffer(Buffer.Type.Index);
			if(count < 0) count = cast(int) ibo.length;
			cgl!glDrawElements(drawMode, count, ibo.glBaseType, cast(void*) (start*ibo.elementsize));

		}else{
			auto vbo = GetBoundBuffer(Buffer.Type.Array);
			if(count < 0) count = cast(int) vbo.length;
			cgl!glDrawArrays(drawMode, start, count);
		}
	}

	// These are called by SetAttribute and probably shouldn't be
	//	called manually
	static void EnableAttributeArray(uint attr){
		cgl!glEnableVertexAttribArray(attr);
	}
	static void DisableAttributeArray(uint attr){
		cgl!glDisableVertexAttribArray(attr);
	}
}