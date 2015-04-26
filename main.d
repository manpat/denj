module main;

import derelict.sdl2.sdl;
import derelict.opengl3.gl3;
import denj.system.window;
import denj.system.input;
import denj.graphics;
import denj.utility;
import denj.math;

import std.string;
import std.random;

// version = TestLog;
// version = TestMath;
// version = TestWindow;
// version = TestInput;
version = TestGraphics;
// version = RunScratch;

void main(){
	ClearLog();

	version(TestLog) RunTest!LogTests();
	version(TestMath) RunTest!MathTests();
	version(TestWindow) RunTest!WindowTests();
	version(TestInput) RunTest!InputTests();
	version(TestGraphics) RunTest!GraphicsTests();
	version(RunScratch) RunTest!Scratch();

	Log("Finished");
	FlushLog();
}

void RunTest(alias test)(){
	Log("Running " ~ test.stringof);
	try{
		test();
	}catch(Exception e){
		LogF("%s:%s: error: in "~test.stringof~": %s", e.file, e.line, e.msg);
		throw e;
	}
	Log(test.stringof ~ " done");
	Log();
}

void LogTests(){
	struct Thing {
		int a = 123;
		float b = 456.7;
		string c = "89 10";
		vec2 d = vec2(0.707, 1.52);
	}

	Log("Denj test", " lelel ", 123);
	Log("Denj test", " lelel ", Thing());
	LogF("Format format %s format %s", Thing(555, 666.0, "abc"), "blah");
}

void MathTests(){
	auto a = vec4(1, 0, 1, 0);
	auto b = vec4(1, 1, 0.4, 0);

	LogF("%s + %s = %s", a, b, a + b);
	Log("TODO: write more math");
}

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
		renderer.Draw();

		renderer3.MakeCurrent();
		glClearColor(0f, 0f, 1f, 1f);
		glClear(GL_COLOR_BUFFER_BIT);
		renderer3.Draw();

		Window.UpdateAll();
		SDL_Delay(50);
	}
}

void InputTests(){
	auto window = new Window(200, 200, "InputTest");
	auto renderer = new Renderer(window);
	auto input = new Input(window);

	while(Window.IsValid()){
		window.Update();
		if(input.KeyPressed(SDLK_ESCAPE)) window.Close();

		if(input.KeyPressed(SDLK_a)){
			glClearColor(1,1,0,1);
		}else if(input.KeyReleased(SDLK_a)){
			glClearColor(0,1,1,1);
		}else if(input.KeyDown(SDLK_s)){
			glClearColor(1,0,1,1);
		}else{
			glClearColor(1,1,1,1);
		}

		glClear(GL_COLOR_BUFFER_BIT);

		renderer.Swap();
		SDL_Delay(50);
	}
}

import std.traits;
import std.conv;

private bool glErrorOccured = false;

ReturnType!func cgl(alias func, string file = __FILE__, size_t line = __LINE__)(ParameterTypeTuple!func t){
	static if(!is(ReturnType!func == void)){
		auto ret = func(t);
	}else{
		func(t);
	}

	if(glErrorOccured){
		throw new Exception(func.stringof ~ " is where the last error occured", file, line);

	}else if(auto e = CheckGLError()){
		throw new Exception(func.stringof ~ " " ~ e, file, line);
	}

	static if(!is(ReturnType!func == void)){
		return ret;
	}
}
private string GLDebugEnumsToString(GLenum source, GLenum type, GLenum severity){
	string ret = "";

	switch(severity){
		case GL_DEBUG_SEVERITY_HIGH: ret ~= "[high]"; break;
		case GL_DEBUG_SEVERITY_MEDIUM: ret ~= "[medium]"; break;
		case GL_DEBUG_SEVERITY_LOW: ret ~= "[low]"; break;
		case GL_DEBUG_SEVERITY_NOTIFICATION: ret ~= "[notification]"; break;
		default: ret ~= "[unknown]";
	}

	ret ~= "\tsrc:";

	switch(source){
		case GL_DEBUG_SOURCE_API: ret ~= " API"; break;
		case GL_DEBUG_SOURCE_WINDOW_SYSTEM: ret ~= " WINDOW_SYSTEM"; break;
		case GL_DEBUG_SOURCE_SHADER_COMPILER: ret ~= " SHADER_COMPILER"; break;
		case GL_DEBUG_SOURCE_THIRD_PARTY: ret ~= " THIRD_PARTY"; break;
		case GL_DEBUG_SOURCE_APPLICATION: ret ~= " APPLICATION"; break;
		case GL_DEBUG_SOURCE_OTHER: ret ~= " OTHER"; break;
		default: ret ~= " unknown";
	}

	ret ~= "\ttype:";

	switch(type){
		case GL_DEBUG_TYPE_ERROR: ret ~= " error"; break;
		case GL_DEBUG_TYPE_DEPRECATED_BEHAVIOR: ret ~= " deprecated behaviour"; break;
		case GL_DEBUG_TYPE_UNDEFINED_BEHAVIOR: ret ~= " undefined behaviour"; break;
		case GL_DEBUG_TYPE_PORTABILITY: ret ~= " portability issue"; break;
		case GL_DEBUG_TYPE_PERFORMANCE: ret ~= " performance issue"; break;
		case GL_DEBUG_TYPE_MARKER: ret ~= " marker"; break;
		case GL_DEBUG_TYPE_PUSH_GROUP: ret ~= " push group"; break;
		case GL_DEBUG_TYPE_POP_GROUP: ret ~= " pop group"; break;
		case GL_DEBUG_TYPE_OTHER: ret ~= " other"; break;
		default: ret ~= " unknown";
	}

	return ret;
}

extern(C) private void GLDebugFunc(GLenum source, GLenum type, GLuint id,
	GLenum severity, GLsizei length, const (GLchar)* message,
	GLvoid* userParam) nothrow{

	import std.string;

	try {
		auto _glErrorOccured = cast(bool*) userParam;
		if(_glErrorOccured) *_glErrorOccured = true;
		
		Log(GLDebugEnumsToString(source, type, severity), "\t\tid: ", id, "\n\t", message.fromStringz);
	}catch(Exception e){

	}
}
private string CheckGLError(){
	GLuint error = glGetError();
	switch(error){
		case GL_INVALID_ENUM:
			return "InvalidEnum";

		case GL_INVALID_VALUE:
			return "InvalidValue";

		case GL_INVALID_OPERATION:
			return "InvalidOperation";

		case GL_INVALID_FRAMEBUFFER_OPERATION:
			return "InvalidFramebufferOperation";

		case GL_OUT_OF_MEMORY:
			return "OutOfMemory";

		case GL_NO_ERROR:
			return null;

		default:
			return "Unhandled GL Error";
	}
}

void InitGLDebugging(){
	cgl!glEnable(GL_DEBUG_OUTPUT);
	cgl!glEnable(GL_DEBUG_OUTPUT_SYNCHRONOUS);

	cgl!glDebugMessageCallback(&GLDebugFunc, cast(const(void)*) &glErrorOccured);
}

void GraphicsTests(){
	auto win = new Window(800, 600, "Shader");
	auto inp = new Input(win);
	auto rend = new Renderer(win, GLContextSettings(3, 2, true));
	InitGLDebugging();

	auto sh = ShaderProgram.LoadFromFile("shader.shader");
	cgl!glUseProgram(sh.glprogram);

	cgl!glEnable(GL_DEPTH_TEST);
	cgl!glEnable(GL_CULL_FACE);
	cgl!glEnable(GL_BLEND);
	cgl!glFrontFace(GL_CW);

	cgl!glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	// uint vbo = 0;
	// uint ebo = 0;
	auto data = [
		vec3(-1, 1,-1),
		vec3( 1,-1,-1),
		vec3( 1, 1, 1),
		vec3(-1,-1, 1),
	];
	ubyte[] indicies = [
		0,1,2,
		0,2,3,
		0,3,1,
		1,3,2,
	];

	auto vbo = new Buffer!vec3();
	auto ebo = new Buffer!ubyte(BufferType.Index);
	vbo.Upload(data);
	ebo.Upload(indicies);

	sh.EnableAttributeArray(0); // Should be handled by renderer

	mat4 projection;
	{
		enum fovy = 80f * PI / 180f;
		enum aspect = 8f/6f;

		enum n = 0.1f;
		enum f = 50f;

		enum r = 1f/tan(fovy/2f);
		enum t = r*aspect;
		projection = mat4(
			r, 0,   0,   0,
			0,   t, 0,   0,
			0,   0,   -(f+n)/(f-n), -2*f*n/(f-n),
			0,   0,   -1,   0,
		);
	}
	sh.SetUniform("projection", projection);

	cgl!glClear(GL_DEPTH_BUFFER_BIT);

	float t = 0f;
	while(win.IsOpen()){
		t += 0.04f;

		auto rot = PI * t;
		auto rotation = mat4(
			cos(rot/5f), 0, sin(rot/5f), 0,
			0, 1, 0, 0,
			-sin(rot/5f), 0, cos(rot/5f), 0,
			0, 0, 0, 1,
		);

		rotation = rotation * mat4(
			1, 0, 0, 0, 
			0, cos(rot/7f), -sin(rot/7f), 0,
			0, sin(rot/7f), cos(rot/7f), 0,
			0, 0, 0, 1,
		);

		auto translation = mat4(
			1, 0, 0, 0,
			0, 1, 0, sin(t*0.3*2f*PI)*0.1,
			0, 0, 1, -4f + sin(t)*0f,
			0, 0, 0, 1,
		);

		sh.SetUniform("modelview", translation*rotation);

		if(inp.KeyPressed(SDLK_ESCAPE)) win.Close();

		win.FrameBegin();
		win.Update();

		cgl!glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);

		vbo.Bind();
		ebo.Bind();

		auto c = t*0.4;

		// Outer loop
		cgl!glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, null);
		cgl!glVertexAttrib2f(1, c, 1f);
		cgl!glDrawElements(GL_LINE_LOOP, cast(int) ebo.length, GL_UNSIGNED_BYTE, null);

		// Inner loop
		auto scale = (mat4.identity*(0.93f));
		scale[3,3] = 1f;
		sh.SetUniform("modelview", translation*rotation*scale);

		cgl!glVertexAttrib2f(1, c*0.3f, 0.5f);
		cgl!glDrawElements(GL_LINE_LOOP, cast(int) ebo.length, GL_UNSIGNED_BYTE, null);

		// Inverted tetra
		scale = (mat4.identity*-(0.4f + sin(t)*0.1f));
		scale[3,3] = 1f;
		sh.SetUniform("modelview", translation*rotation*scale);

		cgl!glVertexAttrib2f(1, c*5f, 1f);
		cgl!glDrawElements(GL_LINE_LOOP, cast(int) ebo.length, GL_UNSIGNED_BYTE, null);

		// Solid tetra
		scale = (mat4.identity*-(0.2f + sin(t)*0.1f));
		scale[3,3] = 1f;
		sh.SetUniform("modelview", translation*rotation*scale);

		cgl!glVertexAttrib2f(1, c*2f, 0.2f);
		cgl!glDrawElements(GL_TRIANGLES, cast(int) ebo.length, GL_UNSIGNED_BYTE, null);

		vbo.Unbind();
		ebo.Unbind();

		rend.Swap();
	}
}

void Scratch(){
	
}