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

		}else if(Input.GetButtonDown(SDL_BUTTON_LEFT)){
			glClearColor(0,0,1,1);
		}else if(Input.GetButtonUp(SDL_BUTTON_LEFT)){
			glClearColor(0,1,0,1);
		}else if(Input.GetButton(SDL_BUTTON_RIGHT)){
			glClearColor(1,0,0,1);
		}else{
			auto mp = Input.GetMousePosition()/2f+0.5f;
			glClearColor(mp.x,mp.y,1,1);
		}

		glClear(GL_COLOR_BUFFER_BIT);

		Window.Swap();
		Window.FrameEnd();
		SDL_Delay(10);
	}
}