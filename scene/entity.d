module denj.scene.entity;

import denj.utility.log; // 
import denj.scene.scene;
import denj.scene.component;
import denj.scene.transform;
import denj.utility.sharedreference;

// TODO: Think about component ordering by importance. i.e., Important/Depended
//	upon things, get updated first
struct Entity {
	// Isn't really useful yet
	size_t id;

	// A shared reference to this entity
	SharedReference!Entity reference;

	// A reference to the owning scene
	Scene owningScene;

	// Should transform be shared? Other objects may hold 
	//	references to, but it won't move if the entity does.
	// If Transforms are ever pooled, this will need to be made
	//	a shared reference.
	Transform* transform = new Transform;

	// Not shared references because these are never moved (by me)
	Component[] components;

	// Reference to the parent of this entity or null if it is a root/free entity
	SharedReference!Entity parent;

	// References to all children of this entity. These are updated/rendered 
	//	independently of this entity. These references are held for 
	SharedReference!Entity[] children;

	// Determines whether or not this entity and children get
	//	updated and rendered.
	bool active = true; 

	// Determines whether or not this entity is being used and if
	//	it can be safely overwritten with new entities.
	// This flag implies that entity is not active and should
	//	not receive updates.
	private bool alive = false;

	// Returns true if this entity is active and all parents
	//	and grandparents are active. 
	// TODO: Make this not recursive. Maybe add a parentsActive flag
	//	that gets updated when parents active state is changed
	@property bool isActive() {
		if(parent){
			return parent.isActive && active;
		}
		return active;
	}

	@property bool isAlive() {
		return alive;
	}

	// Resets entity to default state
	void Init(){
		alive = true;
		active = true;
		*transform = Transform.init;
		components = [];
		children = [];
	}

	// Sets alive flag to false, and notifies children and components
	//	about their impending doom
	void Destroy(){
		foreach(ref c; components){
			c.Destroy();
			c.destroy(); // This is D's class destroy
			c = null;
		}

		foreach(ref c; children){
			if(c){
				owningScene.DestroyEntity(c);
			}
		}

		alive = false;
	}

	void Update(){
		foreach(ref c; components){
			c.Update();
		}
	}

	// TODO: Detect if C has RenderableComponent interface and add to rendering
	//	queue
	C AddComponent(C, A...)(A a){
		static assert(is(C : Component), "Entity cannot add a component of type "~C.stringof);

		static if (is(C : RenderableComponent)){
			Log("Component ", C.stringof, " is renderable");
		}

		// TODO: Maybe add a component pool?
		// TODO: Lookup how to do pools with classes
		auto c = new C(a);
		c.owner = reference;
		components ~= c;
		return c;
	}

	// TODO: RemoveComponent[s]
	// TODO: (Find/Get)Component[s][InChildren]
	// TODO: HasComponent

	void SetParent(SharedReference!Entity p){
		p.AddChild(reference);
	}

	void AddChild(SharedReference!Entity c){
		children ~= c;
		c.parent = reference;
		c.transform.parent = transform;
	}
	// TODO: FindChildren
	// TODO: RemoveChildren
}