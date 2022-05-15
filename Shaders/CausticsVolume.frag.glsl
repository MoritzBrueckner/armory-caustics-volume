#version 450

#include "../std/gbuffer.glsl" // packFloatInt16(), getPos()

uniform sampler2D depthtex;
uniform sampler2D tex_caustics;
uniform float time;
uniform vec2 screenSize;
uniform vec2 cameraProj;
uniform vec3 camPos;
uniform vec3 camDir;
uniform vec3 sunColor;
uniform mat4 sunWorldMat;
uniform mat4 IW;

// World-space position
in vec3 wpos;

// Gbuffer output. Deferred rendering uses the following layout:
// [0]: normal x      normal y      roughness     metallic/matID
// [1]: base color r  base color g  base color b  occlusion/specular
out vec4 fragColor[2];

const float CAUSTICS_SPEED = 0.04;
const float CAUSTICS_SCALE = 0.2;
const float CAUSTICS_STRENGTH = 2.4;
const float EDGE_FADE_RADIUS = 0.3;
const float EDGE_FADE_OFFSET = 0.2;

/** ----- DEBUG SECTION ----- **/
    #define DEBUG_DRAW_DEPTH 0
    #define DEBUG_DRAW_CAMDIR 1
    #define DEBUG_DRAW_VIEWRAY 2
    #define DEBUG_DRAW_WORLDPOS 3
    #define DEBUG_DRAW_OBJPOS 4
    #define DEBUG_DRAW_EDGE_FADE_MASK 5

    // #define DEBUG // Uncomment to enable debug drawing
    #define DEBUG_DRAW_MODE DEBUG_DRAW_EDGE_FADE_MASK // choose debug mode
/** ----- END OF DEBUG SECTION ----- **/

void main() {
    vec2 screenCoords = gl_FragCoord.xy / screenSize;

    float depth = textureLod(depthtex, screenCoords, 0.0).r * 2.0 - 1.0;
    if (depth == 1.0) discard;

    // Reconstruct world and object positions of each fragment (ignoring the caustics volume mesh)
    vec3 viewRay = normalize(wpos - camPos);
    vec3 worldPos = getPos(camPos, camDir, viewRay, depth, cameraProj);
    vec3 objPos = (IW * vec4(worldPos, 1.0)).xyz;

    // Fade out at the edges
    vec3 edgeFadeMaskXYZ = vec3(1.0) - smoothstep(1.0 - EDGE_FADE_RADIUS, 1.0, abs(objPos) + EDGE_FADE_OFFSET);
    float edgeFadeMask = edgeFadeMaskXYZ.x * edgeFadeMaskXYZ.y * edgeFadeMaskXYZ.z;
    if (edgeFadeMask == 0) discard;

    // Sample caustics texture
    vec2 uv = (vec4(worldPos, 1.0) * sunWorldMat).xy * CAUSTICS_SCALE;

    vec2 uv1 = uv + time * CAUSTICS_SPEED;
    vec2 uv2 = uv * -1.0 + time * CAUSTICS_SPEED * 0.5;

    vec3 causticstex = texture(tex_caustics, uv1).rgb;
    vec3 causticstex2 = texture(tex_caustics, uv2).rgb;

    vec3 caustics = min(causticstex, causticstex2) * edgeFadeMask;

    #ifdef DEBUG
        #if DEBUG_DRAW_MODE == DEBUG_DRAW_DEPTH
            vec3 basecol = depth.xxx;
        #elif DEBUG_DRAW_MODE == DEBUG_DRAW_CAMDIR
            vec3 basecol = max(camDir, vec3(0.0));
        #elif DEBUG_DRAW_MODE == DEBUG_DRAW_VIEWRAY
            vec3 basecol = max(viewRay, vec3(0.0));
        #elif DEBUG_DRAW_MODE == DEBUG_DRAW_WORLDPOS
            vec3 basecol = fract(worldPos);
        #elif DEBUG_DRAW_MODE == DEBUG_DRAW_OBJPOS
            vec3 basecol = fract(objPos);
        #elif DEBUG_DRAW_MODE == DEBUG_DRAW_BOX_MASK
            vec3 basecol = vec3(boundingBoxMask);
        #elif DEBUG_DRAW_MODE == DEBUG_DRAW_EDGE_FADE_MASK
            vec3 basecol = vec3(edgeFadeMask);
        #endif
    #else
        caustics *= caustics;
        vec3 basecol = caustics * sunColor * CAUSTICS_STRENGTH;
    #endif

    // Store in gbuffer (see layout table above)
    #ifdef DEBUG
        const uint materialId = 1; // Emission
        const float roughness = 1.0;
        const float metallic = 0.0;
        fragColor[0] = vec4(normalize(vec3(0.5, 0.5, 1.0)).xy, roughness, packFloatInt16(metallic, materialId));
    #else
        fragColor[0] = fragColor[0].xyzw;
    #endif
    fragColor[1] = vec4(basecol.rgb, fragColor[1].w);
}
