#version 130
// Pixel perfect grid scaler
// By droid_42
// license: GPL General Public License v3

#pragma parameter sub_red "Pixel border brightness R" 0.76 0.0 1.0 0.01
#pragma parameter sub_green "Pixel border brightness G" 0.74 0.0 1.0 0.01
#pragma parameter sub_blue "Pixel border brightness B" 0.8 0.0 1.0 0.01

#pragma parameter f_red "Pixel brightness R" 1.04 0.0 1.5 0.01
#pragma parameter f_green "Pixel brightness G" 1.03 0.0 1.5 0.01
#pragma parameter f_blue "Pixel brightness B" 1.02 0.0 1.5 0.01


#pragma parameter offset_x "Shader x offset" 0.0 0.0 7.0 1.0
#pragma parameter offset_y "Shader y offset" 0.0 0.0 7.0 1.0

#pragma parameter h_scale "Horizontal line frequency" 3 2.666667 3.0 0.333333
#pragma parameter h_str "Horizontal line strength" 0.33 0.0 1.0 0.01

#if defined(VERTEX)

#if __VERSION__ >= 130
#define COMPAT_VARYING out
#define COMPAT_ATTRIBUTE in
#define COMPAT_TEXTURE texture
#else
#define COMPAT_VARYING varying
#define COMPAT_ATTRIBUTE attribute
#define COMPAT_TEXTURE texture2D
#endif

#ifdef GL_ES
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

COMPAT_ATTRIBUTE vec4 VertexCoord;
COMPAT_ATTRIBUTE vec4 COLOR;
COMPAT_ATTRIBUTE vec4 TexCoord;
COMPAT_VARYING vec4 COL0;
COMPAT_VARYING vec4 TEX0;

vec4 _oPosition1;
uniform mat4 MVPMatrix;
uniform COMPAT_PRECISION vec2 OutputSize;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;

// compatibility #defines
#define vTexCoord TEX0.xy
#define SourceSize vec4(TextureSize, 1.0 / TextureSize) //either TextureSize or InputSize
#define OutSize vec4(OutputSize, 1.0 / OutputSize)

void main()
{
	gl_Position = MVPMatrix * VertexCoord;
	TEX0.xy = TexCoord.xy;
}

#elif defined(FRAGMENT)

#ifdef GL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

#if __VERSION__ >= 130
#define COMPAT_VARYING in
#define COMPAT_TEXTURE texture
out COMPAT_PRECISION vec4 FragColor;
#else
#define COMPAT_VARYING varying
#define FragColor gl_FragColor
#define COMPAT_TEXTURE texture2D
#endif

uniform COMPAT_PRECISION vec2 OutputSize;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;
uniform sampler2D Texture;
COMPAT_VARYING vec4 TEX0;

// compatibility #defines
#define Source Texture
#define vTexCoord TEX0.xy

#define SourceSize vec4(TextureSize, 1.0 / TextureSize) //either TextureSize or InputSize
#define OutSize vec4(OutputSize, 1.0 / OutputSize)

#ifdef PARAMETER_UNIFORM
uniform COMPAT_PRECISION float sub_red;
uniform COMPAT_PRECISION float sub_green;
uniform COMPAT_PRECISION float sub_blue;

uniform COMPAT_PRECISION float f_red;
uniform COMPAT_PRECISION float f_green;
uniform COMPAT_PRECISION float f_blue;

uniform COMPAT_PRECISION float offset_x;
uniform COMPAT_PRECISION float offset_y;

uniform COMPAT_PRECISION float h_scale;
uniform COMPAT_PRECISION float h_str;
#else
#define sub_red 0.76
#define sub_green 0.74
#define sub_blue 0.80

#define f_red 1.04
#define f_green 1.03
#define f_blue 1.02

#define offset_x 0.0
#define offset_y 0.0

#define h_scale 3.0
#define h_str 0.33
#endif

float hBar(){
	return max(h_str, min(mod(gl_FragCoord.y - offset_y, h_scale), 1.0));
}

vec3 subPixel(){
	float xCycle = mod(gl_FragCoord.x - offset_x, 8.0);

	return xCycle < 1.0 ? vec3(0.0, sub_green, f_blue)
	: xCycle < 2.0 ? vec3(f_red, f_green, f_blue)
	: xCycle < 3.0 ? vec3(sub_red, 0.0, 0.0)
	: xCycle < 4.0 ? vec3(sub_red, f_green, f_blue)
	: xCycle < 5.0 ? vec3(f_red, f_green, sub_blue)
	: xCycle < 6.0 ? vec3(0.0, 0.0, sub_blue)
	: xCycle < 7.0 ? vec3(f_red, f_green, f_blue)
	: vec3(f_red, sub_green, 0.0);
}

void main()
{
	vec3 base = COMPAT_TEXTURE(Source, vTexCoord.xy).rgb;
	base *= subPixel() * hBar();

	FragColor = vec4(base, 1.0);
}
#endif
