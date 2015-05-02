module denj.system.input;

import denj.system.common;
import denj.system.window;
import denj.utility;

enum KeyState {
	None,
	Up,
	Down
}

alias KeyState ButtonState;

// TODO: Figure out how to handle/store gamepad input
// TODO: Grab mouse input. Mousewarping

struct Input {
	static private{
		KeyState[uint] keys;
		// mouse button states
		// current mouse position
		// mouse delta

		uint[] changedKeys;
		// changed mouse buttons
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
				auto b = &e.button;
				HandleMouseButton(b.button, ButtonState.Down, b.x, b.y);
				break;
			}

			case SDL_MOUSEBUTTONUP:{
				auto b = &e.button;
				HandleMouseButton(b.button, ButtonState.Up, b.x, b.y);
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

	static private void HandleMouseButton(uint button, ButtonState state, int x, int y){
		Log("Click ", button, " ", x, " ", y);
	}

	static int mx;
	static private void HandleMouseMove(int x, int y, uint bstate){
		mx = x;
		Log("Move ", x, " ", y, " ", bstate);
	}

	static private void FrameEnd(){
		changedKeys = [];
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

	// TODO: GetMouseButton[Down|Up]
	// TODO: GetMousePosition
	// TODO: GetMouseMovement
}