#version 450

uniform mat4 WVP;
uniform mat4 W;

in vec4 pos; // pos.xyz, nor.w

out vec3 wpos;

void main() {
    vec4 wp = W * vec4(pos.xyz, 1.0);
    wpos = wp.xyz / wp.w;

    gl_Position = WVP * vec4(pos.xyz, 1.0);
}
