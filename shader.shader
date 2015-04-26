#version 330
#type vertex

layout(location=0) in vec3 pos;
layout(location=1) in vec2 huealpha;
out vec4 vcol;
out vec2 vpos;

uniform mat4 projection;
uniform mat4 modelview;

vec3 hsv2rgb(vec3 c){
	vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y) * c.z;
}

void main(){
	vcol = vec4(hsv2rgb(vec3(huealpha.x, 0.8, 0.7)), huealpha.y);
	vpos = pos.xy;

	gl_Position = projection * modelview * vec4(pos, 1);
}

#type fragment

in vec4 vcol;
in vec2 vpos;
layout(location=0) out vec4 color;

uniform float frequency;

void main(){
	color = vcol;
}