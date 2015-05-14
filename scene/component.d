module denj.scene.component;

import denj.scene.entity;

class Component {
	Entity owner;

	void OnUpdate() {};
	void OnRender() {};
	void OnDestroy() {};
}