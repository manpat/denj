module denj.scene.component;

import denj.scene.entity;
import denj.utility.sharedreference;

class Component {
	SharedReference!Entity owner;
	string typeString = "Component";
	bool active = true;

	final void Update() {
		if(active) OnUpdate();
	}

	// Should OnDestroy be called regardless of whether or not
	//	the component is active?
	final void Destroy() {
		OnDestroy();
	}

	// Called once per frame, after input and before rendering
	void OnUpdate() {};

	// Called when the component gets destroyed, just before the
	//	owning entity becomes invalid.
	void OnDestroy() {};
}

// TODO: Maybe move this to somewhere that does rendering
interface RenderableComponent {
	void OnRender();
}