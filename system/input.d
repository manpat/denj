module denj.system.input;

import denj.system.common;
import denj.system.window;
import denj.utility;

enum KeyState {
	None,
	Up,
	Down
}

struct Input {
	KeyState[uint] keys;
	uint[] changedKeys;

	this(ref Window win){
		win.HookSDL(SDL_KEYDOWN, &HandleSDL);
		win.HookSDL(SDL_KEYUP, &HandleSDL);
		win.HookFrameEnd(&FrameEnd);
	}

	private void HandleSDL(SDL_Event* e){
		switch(e.type){
			case SDL_KEYDOWN:
				if(e.key.repeat == 0){
					HandleKeypress(e.key.keysym.sym, KeyState.Down);
				}
				break;

			case SDL_KEYUP:
				HandleKeypress(e.key.keysym.sym, KeyState.Up);
				break;

			default: 
			break;
		}
	}

	private void HandleKeypress(uint key, KeyState state){
		keys[key] = state;
		changedKeys ~= key;
	}

	private void FrameEnd(){
		changedKeys = [];
	}

	// Checks if a given key is pressed
	public bool GetKey(uint key){
		return keys.get(key, KeyState.None) == KeyState.Down;
	}

	// Checks if a given key has been pressed this frame
	public bool GetKeyDown(uint key){
		foreach(k; changedKeys){
			if(k == key && keys.get(key, KeyState.None) == KeyState.Down) return true;
		}

		return false;
	}

	// Checks if a given key has been released this frame
	public bool GetKeyUp(uint key){
		foreach(k; changedKeys){
			if(k == key && keys.get(key, KeyState.None) == KeyState.Up) return true;
		}

		return false;
	}
}