module denj.scene.transform;

import denj.math;

struct Transform {
	Transform* parent = null;
	vec3 position = vec3.zero;
	mat3 rotation = mat3.identity;
}