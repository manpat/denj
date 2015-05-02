module tests.input;

import denj.utility;
import denj.system.common;
import denj.system.window;
import denj.system.input;
import denj.graphics.common;
import denj.graphics.renderer;

import std.string;

void InputTests(){
	Window.Init(200, 200, "InputTest");
	Renderer.Init(GLContextSettings(3, 2));
	Input.Init();

	while(Window.IsOpen()){
		Window.FrameBegin();

		if(Input.GetKeyDown(SDLK_ESCAPE)) {
			Window.Close();
			break;
		}

		if(Input.GetKeyDown(SDLK_a)){
			glClearColor(1,1,0,1);
		}else if(Input.GetKeyUp(SDLK_a)){
			glClearColor(0,1,1,1);
		}else if(Input.GetKey(SDLK_s)){
			glClearColor(1,0,1,1);
		}else{
			auto g = Input.mx / cast(float) Window.GetWidth();
			glClearColor(g,g,g,1);
		}

		glClear(GL_COLOR_BUFFER_BIT);

		Window.Swap();
		Window.FrameEnd();
		SDL_Delay(50);
	}
}