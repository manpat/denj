module denj.system.input;

import denj.system.common;
import denj.system.window;
import denj.utility;
import denj.math.vector;

enum KeyState {
	None,
	Up,
	Down
}

alias KeyState ButtonState;

// TODO: Figure out how to handle/store gamepad input
// TODO: Grab mouse input. Mousewarping
// TODO: Remove changed* arrays and instead have a separate state

struct Input {
	static private{
		KeyState[uint] keys;
		ButtonState[uint] buttons;
		vec2 mpos;
		vec2 dmpos;

		uint[] changedKeys;
		uint[] changedButtons;
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

			case SDL_MOUSEMOTION:{
				auto m = &e.motion;
				HandleMouseMove(m.x, m.y, m.state);
				break;
			}

			default:
				LogF("Unhandled SDLEvent in Input 0x%x", e.type);
				break;
		}
	}

	static private void HandleKeypress(uint key, KeyState state){
		keys[key] = state;
		changedKeys ~= key;
	}

	static private void HandleMouseButton(uint button, ButtonState state){
		buttons[button] = state;
		changedButtons ~= button;
	}

	static private void HandleMouseMove(int x, int y, uint bstate){
		vec2 nmpos;
		nmpos.x = x / cast(float) Window.GetWidth()  * 2f - 1f;
		nmpos.y =-y / cast(float) Window.GetHeight() * 2f + 1f;
		dmpos = nmpos - mpos;
		mpos = nmpos;
	}

	static private void FrameEnd(){
		changedKeys = [];
		changedButtons = [];
		dmpos = vec2.zero;
	}

	// Checks if a given key is pressed
	static bool GetKey(uint key){
		return keys.get(key, KeyState.None) == KeyState.Down;
	}

	// Checks if a given key has been pressed this frame
	static bool GetKeyDown(uint key){
		foreach(k; changedKeys){
			if(k == key && keys.get(key, KeyState.None) == KeyState.Down) return true;
		}

		return false;
	}

	// Checks if a given key has been released this frame
	static bool GetKeyUp(uint key){
		foreach(k; changedKeys){
			if(k == key && keys.get(key, KeyState.None) == KeyState.Up) return true;
		}

		return false;
	}

	// Checks if a given button is pressed
	static bool GetButton(uint button){
		return buttons.get(button, ButtonState.None) == ButtonState.Down;
	}

	// Checks if a given button has been pressed this frame
	static bool GetButtonDown(uint button){
		foreach(k; changedButtons){
			if(k == button && buttons.get(button, ButtonState.None) == ButtonState.Down) return true;
		}

		return false;
	}

	// Checks if a given button has been released this frame
	static bool GetButtonUp(uint button){
		foreach(k; changedButtons){
			if(k == button && buttons.get(button, ButtonState.None) == ButtonState.Up) return true;
		}

		return false;
	}

	static vec2 GetMousePosition(){
		return mpos;
	}

	static vec2 GetMouseDelta(){
		return dmpos;
	}
}