#version 320
#type vertex

in vec4 vert;
in vec3 color;
out float blah;

uniform sampler2D tex;

void main(){
	blah = vert.y + color.g;
	gl_Position = vert;
}

#type fragment

in float blah;
out vec4 output;

void main(){
	output = vec4(blah)
}