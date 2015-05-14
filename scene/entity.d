module denj.scene.entity;

import denj.scene.component;
import denj.scene.transform;

struct Entity {
	size_t id; 
	Transform transform = new Transform();
	Component[] components;
	Entity[] children;

	// Determines whether or not this entity and children get
	//	updated and rendered.
	bool active = true; 

	// Determines whether or not this entity is being used and if
	//	it can be safely overwritten with new entities.
	//	This flag implies that entity is not active.
	private bool alive = false;

	@property bool isAlive() {
		return alive;
	}

	// Resets entity to default state
	void Init(){
		alive = true;
		active = true;
		transform = Transform.init;
		components = [];
		children = [];
	}

	void Destroy(){
		alive = false;
		// Notify components
		// Notify children
	}

	C AddComponent(C, A...)(A a){
		static assert(is(C : Component), "Entity cannot add a component of type "~C.stringof);

		auto c = new C(a);
		c.owner = this;
		components ~= c;
		return c;
	}
}