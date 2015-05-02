module tests.input;

import derelict.sdl2.sdl;

import denj.utility;
import denj.system.window;
import denj.system.input;
import denj.graphics.common;
import denj.graphics.renderer;

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