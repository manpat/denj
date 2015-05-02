module tests.input;

import denj.utility;
import denj.system.common;
import denj.system.window;
import denj.system.input;
import denj.graphics.common;
import denj.graphics.renderer;

void InputTests(){
	auto window = Window(200, 200, "InputTest");
	auto renderer = Renderer(window);
	auto input = Input(window);

	while(window.IsOpen()){
		window.FrameBegin();
		if(input.GetKeyDown(SDLK_ESCAPE)) {
			window.Close();
			break;
		}

		if(input.GetKeyDown(SDLK_a)){
			glClearColor(1,1,0,1);
		}else if(input.GetKeyUp(SDLK_a)){
			glClearColor(0,1,1,1);
		}else if(input.GetKey(SDLK_s)){
			glClearColor(1,0,1,1);
		}else{
			glClearColor(1,1,1,1);
		}

		glClear(GL_COLOR_BUFFER_BIT);

		window.Swap();
		window.FrameEnd();
		SDL_Delay(50);
	}
}