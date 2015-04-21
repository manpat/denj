module main;

import derelict.sdl2.sdl;
import derelict.opengl3.gl3;
import denj.system.window;
import denj.system.input;
import denj.utility;
import denj.math;
import std.math;

import std.string;

version = TestLog;
//version = TestMath;
//version = TestWindow;
//version = TestInput;
version = RunScratch;

void main(){
	ClearLog();

	version(TestLog) RunTest!LogTests();
	version(TestMath) RunTest!MathTests();
	version(TestWindow) RunTest!WindowTests();
	version(TestInput) RunTest!InputTests();
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
		window.MakeCurrent();
		glClearColor(1f, 0f, 0f, 1f);
		glClear(GL_COLOR_BUFFER_BIT);
		window.Swap();

		window2.MakeCurrent();
		glClearColor(0f, 1f, 0f, 1f);
		glClear(GL_COLOR_BUFFER_BIT);
		window2.Swap();

		window3.MakeCurrent();
		glClearColor(0f, 0f, 1f, 1f);
		glClear(GL_COLOR_BUFFER_BIT);
		window3.Swap();

		Window.UpdateAll();
		SDL_Delay(50);
	}
}

void InputTests(){
	auto window = new Window(200, 200, "InputTest");
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

		window.Swap();
		SDL_Delay(50);
	}
}

void Scratch(){
	auto window = new Window(800, 600, "Thing");
	auto window2 = new Window(200, 200, "Thing2");
	auto input = new Input(window);
	auto input2 = new Input(window2);

	window.MakeCurrent();

	uint vao;
	glGenVertexArrays(1, &vao);
	glBindVertexArray(vao);

	glFrontFace(GL_CW);

	void RecalcBuffer(uint vbo, uint sides){
		auto anginc = 2f*PI/cast(float)sides;
		vec2[] buffer;

		foreach(i; 0..sides){
			auto f = cast(float) i;
			buffer ~= vec2(cos(anginc*f), sin(anginc*f));
		}

		glBindBuffer(GL_ARRAY_BUFFER, vbo);
		glBufferData(GL_ARRAY_BUFFER, buffer.length*2*float.sizeof, buffer.ptr, GL_STATIC_DRAW);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
	}

	uint vbo = 0;
	glGenBuffers(1, &vbo);
	RecalcBuffer(vbo, 3);

	auto program = glCreateProgram();
	{
		auto vsrc = 
		`#version 330

		in vec2 pos;
		out float inst;
		void main(){
			gl_Position = vec4(0.995*pos/(gl_InstanceID*0.8+1.0), 0, 1);
			inst = gl_InstanceID*1.0;
		}`.dup ~ '\0';

		auto fsrc = 
		`#version 330

		in float inst;
		out vec4 color;
		void main(){
			color = vec4(1/(inst*0.5), 0.2, inst/10.0 + 0.2, 1);
		}`.dup ~ '\0';
		
		auto vsh = glCreateShader(GL_VERTEX_SHADER);
		auto vsrcp = vsrc.ptr;
		glShaderSource(vsh, 1, &vsrcp, null);
		glCompileShader(vsh);
		GLint status;
		glGetShaderiv(vsh, GL_COMPILE_STATUS, &status);
		if(status == GL_FALSE){
			char[] buffer = new char[512];
			glGetShaderInfoLog(vsh, 512, null, buffer.ptr);

			Log(buffer);
			throw new Exception("Shader compile fail");
		}

		auto fsh = glCreateShader(GL_FRAGMENT_SHADER);
		auto fsrcp = fsrc.ptr;
		glShaderSource(fsh, 1, &fsrcp, null);
		glCompileShader(fsh);
		glGetShaderiv(fsh, GL_COMPILE_STATUS, &status);
		if(status == GL_FALSE){
			char[] buffer = new char[512];
			glGetShaderInfoLog(fsh, 512, null, buffer.ptr);

			Log(buffer);
			throw new Exception("Shader compile fail");
		}

		glAttachShader(program, vsh);
		glAttachShader(program, fsh);
		glBindFragDataLocation(program, 0, "color");
		glLinkProgram(program);
		glDeleteShader(vsh);
		glDeleteShader(fsh);

		glUseProgram(program);
	}

	struct DrawArraysIndirectCommand {
		uint count;
		uint instances;
		uint first = 0;
		uint baseInstance = 0;
	}

	auto cmd = DrawArraysIndirectCommand(3, 32, 0, 0);

	while(Window.IsValid()){
		Window.FrameBegin();
		Window.UpdateAll();
		if(input2.KeyDown(SDLK_ESCAPE)) window.Close();

		window.MakeCurrent();
		glUseProgram(program);
		enum grey = 0.1f;
		glClearColor(grey, grey, grey, 1f);
		glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);

		glEnableVertexAttribArray(0);
		glBindBuffer(GL_ARRAY_BUFFER, vbo);
		glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, null);
		glDrawArraysIndirect(GL_LINE_LOOP, &cmd);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
		glDisableVertexAttribArray(0);

		if(input.KeyPressed(SDLK_a)){
			if(cmd.count > 3) cmd.count--;
			RecalcBuffer(vbo, cmd.count);

		}else if(input.KeyPressed(SDLK_s) || input.KeyDown(SDLK_d)){
			cmd.count++;
			RecalcBuffer(vbo, cmd.count);
		}

		window.Swap();

		window2.MakeCurrent();
		if(input2.KeyPressed(SDLK_a)){
			glClearColor(1,1,0,1);
		}else if(input2.KeyReleased(SDLK_a)){
			glClearColor(0,1,1,1);
		}else if(input2.KeyDown(SDLK_s)){
			glClearColor(1,0,1,1);
		}else{
			glClearColor(1,1,1,1);
		}

		glClear(GL_COLOR_BUFFER_BIT);
		window2.Swap();

		SDL_Delay(20);
	}
}