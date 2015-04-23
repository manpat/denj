#version 330
#type vertex

layout(location=0) in vec2 pos;
layout(location=1) in vec3 col;
out vec3 vcol;
out vec2 vpos;

void main(){
	vcol = col;
	vpos = pos;
	gl_Position = vec4(pos, 0, 1);
}

#type fragment

in vec3 vcol;
in vec2 vpos;
layout(location=0) out vec4 color;

uniform float frequency;

void main(){
	float x = vpos.x;
	x *= 2f * 3.1415926 * frequency;

	float d = (vpos.y-sin(x));
	d = clamp(1f - sqrt(d*d)*10f, 0f, 1f);
	d *= d;

	color = vec4(d * vcol, 1f);
}