module denj.system.input;

import denj.system.common;
import denj.system.window;
import denj.utility;
import denj.math.vector;

enum KeyState {
	None,
	Up,
	Down,

	ThisFrame = 0x8
}

alias KeyState ButtonState;

// TODO: Figure out how to handle/store gamepad input
// TODO: Grab mouse input. Mousewarping
// TODO: Remove changed* arrays and instead have a separate state

struct Input {
	static private{
		KeyState[uint] keys;
		ButtonState[uint] buttons;
		vec2 mpos = vec2.zero;
		vec2 dmpos = vec2.zero;

		bool mouseCapture = false;
	}

	static void Init(){
		Window.HookSDL(SDL_KEYDOWN, 		(e) => HandleSDL(e));
		Window.HookSDL(SDL_KEYUP, 			(e) => HandleSDL(e));

		Window.HookSDL(SDL_MOUSEMOTION, 	(e) => HandleSDL(e));
		Window.HookSDL(SDL_MOUSEBUTTONDOWN, (e) => HandleSDL(e));
		Window.HookSDL(SDL_MOUSEBUTTONUP, 	(e) => HandleSDL(e));

		// Window.HookSDL(SDL_CONTROLLERDEVICEADDED, &HandleSDL);
		// Window.HookSDL(SDL_CONTROLLERDEVICEREMOVED, &HandleSDL);
		// Window.HookSDL(SDL_CONTROLLERBUTTONDOWN, &HandleSDL);
		// Window.HookSDL(SDL_CONTROLLERBUTTONUP, &HandleSDL);
		// Window.HookSDL(SDL_CONTROLLERAXISMOTION, &HandleSDL);

		Window.HookFrameBegin(() => FrameBegin);
		Window.HookFrameEnd(() => FrameEnd);
	}

	static private void HandleSDL(SDL_Event* e){
		switch(e.type){
			case SDL_KEYDOWN:
				if(e.key.repeat == 0){
					HandleKeypress(e.key.keysym.sym, KeyState.Down);
				}
				break;

			case SDL_KEYUP:
				HandleKeypress(e.key.keysym.sym, KeyState.Up);
				break;

			case SDL_MOUSEBUTTONDOWN:{
				HandleMouseButton(e.button.button, ButtonState.Down);
				break;
			}

			case SDL_MOUSEBUTTONUP:{
				HandleMouseButton(e.button.button, ButtonState.Up);
				break;
			}

			case SDL_MOUSEMOTION:
				if(!mouseCapture){
					auto m = &e.motion;
					HandleMouseMove(m.x, m.y);
				}
				break;

			default:
				LogF("Unhandled SDLEvent in Input 0x%x", e.type);
				break;
		}
	}

	static private void HandleKeypress(uint key, KeyState state){
		keys[key] = state | KeyState.ThisFrame;
	}

	static private void HandleMouseButton(uint button, ButtonState state){
		buttons[button] = state | ButtonState.ThisFrame;
	}

	static private void HandleMouseMove(int x, int y){
		auto wsize = vec2(
			cast(float) Window.GetWidth(),
			cast(float) Window.GetHeight());

		vec2 nmpos;
		nmpos.x = x / wsize.x * 2f - 1f;
		nmpos.y =-y / wsize.y * 2f + 1f;

		if(mouseCapture){
			dmpos = nmpos;
			mpos = mpos + nmpos;
		}else{
			dmpos = nmpos - mpos;
			mpos = nmpos;
		}
	}

	static private void FrameBegin(){
		if(mouseCapture){
			int mx, my;
			SDL_GetMouseState(&mx, &my);
			HandleMouseMove(mx, my);
			SDL_WarpMouseInWindow(Window.GetSDLWindow(), Window.GetWidth()/2, Window.GetHeight()/2);
		}
	}
	static private void FrameEnd(){
		foreach(ref k; keys){
			k &= ~KeyState.ThisFrame;
		}

		foreach(ref k; buttons){
			k &= ~ButtonState.ThisFrame;
		}

		dmpos = vec2.zero;
	}

	// Checks if a given key is pressed
	static bool GetKey(uint key){
		return (keys.get(key, KeyState.None) & KeyState.Down) != 0;
	}

	// Checks if a given key has been pressed this frame
	static bool GetKeyDown(uint key){
		return keys.get(key, KeyState.None) == (KeyState.Down|KeyState.ThisFrame);
	}

	// Checks if a given key has been released this frame
	static bool GetKeyUp(uint key){
		return keys.get(key, KeyState.None) == (KeyState.Up|KeyState.ThisFrame);
	}

	// Checks if a given mouse button is pressed
	static bool GetButton(uint button){
		return (buttons.get(button, ButtonState.None) & ButtonState.Down) != 0;
	}

	// Checks if a given mouse button has been pressed this frame
	static bool GetButtonDown(uint button){
		return buttons.get(button, ButtonState.None) == (ButtonState.Down|ButtonState.ThisFrame);
	}

	// Checks if a given mouse button has been released this frame
	static bool GetButtonUp(uint button){
		return buttons.get(button, ButtonState.None) == (ButtonState.Up|ButtonState.ThisFrame);
	}

	static vec2 GetMousePosition(){
		return mpos;
	}

	// Gets change in mouse position since previous frame
	static vec2 GetMouseDelta(){
		return dmpos;
	}

	////////////////////// Settings /////////////////////

	static void SetMouseCapture(bool capture = false){
		mouseCapture = capture;
		// show/hide cursor
	}
}