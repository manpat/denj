module main;

import derelict.sdl2.sdl;
import derelict.opengl3.gl3;
import denj.system.window;
import denj.system.input;
import denj.graphics.common;
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

import denj.graphics.errorchecking;

void GraphicsTests(){
	auto win = new Window(800, 600, "Shader");
	auto inp = new Input(win);
	auto rend = new Renderer(win, GLContextSettings(3, 2, true));

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
	auto cbo = new Buffer!vec2();
	auto ebo = new Buffer!ubyte(BufferType.Index);
	vbo.Upload(data);
	ebo.Upload(indicies);

	{
		cbo.Bind();
		cbo.AllocateStorage(data.length);
		auto cbuff = cbo.Map()[0..cbo.length];

		float h = 0f;
		foreach(ref c; cbuff){
			c = vec2(h,1f);
			h += 0.25f;
		}

		cbo.Unmap();
		cbo.Unbind();
	}

	mat4 projection;
	{ // TODO: Move to matrix math module
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
	sh.SetUniform("view", mat4.Translation(vec3(0,0,-4f)));

	cgl!glClear(GL_DEPTH_BUFFER_BIT);
	cgl!glPointSize(4f);

	float t = 0f;
	while(win.IsOpen()){
		win.FrameBegin();
		win.Update();

		t += 0.04f;

		// TODO: Move transform code to matrix math module
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

		auto translation = mat4.Translation(vec3(0, sin(t*0.3*2f*PI)*0.1, 0));

		sh.SetUniform("model", translation*rotation);

		if(inp.KeyPressed(SDLK_ESCAPE)) win.Close();

		cgl!glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);

		rend.SetAttribute(0, vbo);
		rend.SetAttribute(1, cbo);

		auto c = t*0.4;

		// Outer points
		cgl!glDrawArrays(GL_POINTS, 0, cast(int) vbo.length);

		// Bind index buffer
		ebo.Bind();

		// Outer loop
		cgl!glDrawElements(GL_LINE_LOOP, cast(int) ebo.length, GetGLType!(ebo.BaseType), null);

		// Inner loop
		sh.SetUniform("model", translation*rotation*mat4.Scale(0.93f));

		rend.SetAttribute(1, vec2(c*0.3f, 1f));
		cgl!glDrawElements(GL_LINE_LOOP, cast(int) ebo.length, GetGLType!(ebo.BaseType), null);

		// Inverted tetra
		sh.SetUniform("model", translation*rotation*mat4.Scale(0.4f + sin(t)*0.1f));

		rend.SetAttribute(1, cbo);
		cgl!glDrawElements(GL_LINE_LOOP, cast(int) ebo.length, GetGLType!(ebo.BaseType), null);

		// Solid tetra
		sh.SetUniform("model", translation*rotation*mat4.Scale(0.3f + sin(t)*0.15f));

		rend.SetAttribute(1, vec2(c*5f, 0.8f));
		cgl!glDrawElements(GL_TRIANGLES, cast(int) ebo.length, GetGLType!(ebo.BaseType), null);

		// Orbiter
		auto orbit = mat4(
			cos(-rot/12f), 0, sin(-rot/12f), 0,
			0, 1, 0, 0,
			-sin(-rot/12f), 0, cos(-rot/12f), 0,
			0, 0, 0, 1,
		) * mat4.Translation(vec3(0,0,-2f));

		sh.SetUniform("model", orbit*rotation*mat4.Scale(0.3f + sin(t*0.5f)*0.08f));
		rend.SetAttribute(1, vec2(c*0.1f, 0.5f));
		cgl!glDrawElements(GL_TRIANGLES, cast(int) ebo.length, GL_UNSIGNED_BYTE, null);

		rend.SetAttribute(1, vec2(c*0.1f, 1f));
		cgl!glDrawElements(GL_LINE_LOOP, cast(int) ebo.length, GL_UNSIGNED_BYTE, null);

		vbo.Unbind();
		cbo.Unbind();
		ebo.Unbind();

		rend.Swap();
	}
}

void Scratch(){
	
}