module denj.system.input;

import derelict.sdl2.sdl;
import denj.system.window;
import denj.utility;

enum KeyState {
	None,
	Up,
	Down
}

class Input {
	KeyState[uint] keys;
	uint[] changedKeys;

	this(Window win = null){
		if(!win)
			win = Window.GetMain();

		if(!win) 
			"Input system requires at least one active window".Except;

		win.HookSDL(SDL_KEYDOWN, &HandleSDL);
		win.HookSDL(SDL_KEYUP, &HandleSDL);
		win.HookFrameBegin(&Update);

		Log("Input initialised for window with id ", win.GetId());
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

	void Update(){
		changedKeys = [];
	}

	void HandleKeypress(uint key, KeyState state){
		Log("Keypress ", key, " ", state);
		keys[key] = state;
		changedKeys ~= key;
	}

	// Checks if a given key is pressed
	public bool KeyDown(uint key){
		return keys.get(key, KeyState.None) == KeyState.Down;
	}

	// Checks if a given key has been pressed this frame
	public bool KeyPressed(uint key){
		foreach(k; changedKeys){
			if(k == key && keys.get(key, KeyState.None) == KeyState.Down) return true;
		}

		return false;
	}

	// Checks if a given key has been released this frame
	public bool KeyReleased(uint key){
		foreach(k; changedKeys){
			if(k == key && keys.get(key, KeyState.None) == KeyState.Up) return true;
		}

		return false;
	}
}