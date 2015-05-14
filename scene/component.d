module denj.scene.component;

import denj.scene.entity;
import denj.utility.sharedreference;

class Component {
	SharedReference!Entity owner;

	void OnUpdate() {};
	void OnRender() {};
	void OnDestroy() {};
}