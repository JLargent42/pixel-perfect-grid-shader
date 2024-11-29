#version 130
// Pixel perfect grid scaler
// By droid_42
// license: GPL General Public License v3

#pragma parameter sub_red "Pixel border brightness R" 0.74 0.0 1.0 0.01
#pragma parameter sub_green "Pixel border brightness G" 0.73 0.0 1.0 0.01
#pragma parameter sub_blue "Pixel border brightness B" 0.76 0.0 1.0 0.01

#pragma parameter f_red "Pixel brightness R" 0.97 0.0 1.5 0.01
#pragma parameter f_green "Pixel brightness G" 0.96 0.0 1.5 0.01
#pragma parameter f_blue "Pixel brightness B" 0.95 0.0 1.5 0.01

#pragma parameter b_red "Boost brightness R" 1.04 0.0 1.5 0.01
#pragma parameter b_green "Boost brightness G" 1.03 0.0 1.5 0.01
#pragma parameter b_blue "Boost brightness B" 1.02 0.0 1.5 0.01


#pragma parameter offset_x "Shader x offset" 0.0 0.0 7.0 1.0
#pragma parameter offset_y "Shader y offset" 0.0 0.0 7.0 1.0

#pragma parameter h_scale "Horizontal line frequency" 3.0 2.666667 3.0 0.333333
#pragma parameter h_str "Horizontal line strength" 0.0 0.0 1.0 0.01

#pragma parameter reducer "Same neighbor reduction x" 1.0 0.0 1.0 0.01
#pragma parameter reducer_y "Same neighbor reduction y" 1.0 0.0 1.0 0.01



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

uniform COMPAT_PRECISION float b_red;
uniform COMPAT_PRECISION float b_green;
uniform COMPAT_PRECISION float b_blue;

uniform COMPAT_PRECISION float offset_x;
uniform COMPAT_PRECISION float offset_y;

uniform COMPAT_PRECISION float h_scale;
uniform COMPAT_PRECISION float h_str;

uniform COMPAT_PRECISION float reducer;
uniform COMPAT_PRECISION float reducer_y;

#else
#define sub_red 0.74
#define sub_green 0.73
#define sub_blue 0.76

#define f_red 0.97
#define f_green 0.96
#define f_blue 0.95

#define b_red 1.04
#define b_green 1.03
#define b_blue 1.02

#define offset_x 0.0
#define offset_y 0.0

#define h_scale 3.0
#define h_str 0.0

#define reducer 1.0
#define reducer_y 1.0

#endif

vec3 hBar(vec3 base, vec3 up){
	float ub = min(mod(gl_FragCoord.y - offset_y, h_scale), 1.0);

	float rd = (1.0 - (ub * abs(base.r - up.r))) * reducer_y;
	float gd = (1.0 - (ub * abs(base.g - up.g))) * reducer_y;
	float bd = (1.0 - (ub * abs(base.b - up.b))) * reducer_y;

	return vec3(max(rd * (1.0 - h_str) + h_str, ub), max(gd * (1.0 - h_str) + h_str, ub), max(bd * (1.0 - h_str) + h_str, ub));
}

vec3 subPixel(float sr, float sg, float sb, float br, float bg, float bb){
	float xCycle = mod(gl_FragCoord.x - offset_x, 8.0);

	return xCycle < 1.0 ? vec3(sr, f_green, bb)
	: xCycle < 2.0 ? vec3(f_red, f_green, bb)
	: xCycle < 3.0 ? vec3(f_red, sg, 0.0)
	: xCycle < 5.0 ? vec3(f_red, bg, f_blue)
	: xCycle < 6.0 ? vec3(0.0, sg, f_blue)
	: xCycle < 7.0 ? vec3(br, f_green, f_blue)
	: vec3(br, f_green, sb);
}

vec3 vFill(vec3 back, vec3 next, float sr, float sb){

	float xCycle = mod(gl_FragCoord.x - offset_x, 8.0);
	return xCycle < 2.0 ? vec3(0.0, 0.0, 0.0)
	: xCycle < 3.0 ? vec3(0.0, 0.0, next.b * sb)
	: xCycle < 5.0 ? vec3(0.0, 0.0, 0.0)
	: xCycle < 6.0 ? vec3(back.r * sr, 0.0, 0.0)
	: vec3(0.0, 0.0, 0.0);
}

void main()
{
	vec3 base = COMPAT_TEXTURE(Source, vTexCoord.xy).rgb;
	vec3 back = COMPAT_TEXTURE(Source, vTexCoord.xy - vec2(1.0 / 480.0, 0.0)).rgb;
	vec3 next = COMPAT_TEXTURE(Source, vTexCoord.xy + vec2(1.0 / 480.0, 0.0)).rgb;
	vec3 up = COMPAT_TEXTURE(Source, vTexCoord.xy + vec2(0.0, 1.0 / 480.0)).rgb;
	vec3 up_back = COMPAT_TEXTURE(Source, vTexCoord.xy + vec2(-1.0 / 480.0, 1.0 / 480.0)).rgb;
	vec3 up_next = COMPAT_TEXTURE(Source, vTexCoord.xy + vec2(1.0 / 480.0, 1.0 / 480.0)).rgb;

	float r_diff = (1.0 - max(abs(base.r - back.r), abs(base.r - next.r))) * reducer;
	float g_diff = (1.0 - max(abs(base.g - back.g), abs(base.g - next.g))) * reducer;
	float b_diff = (1.0 - max(abs(base.b - back.b), abs(base.b - next.b))) * reducer;

	float sr = f_red * r_diff + (sub_red * (1.0 - r_diff));
	float sg = f_green * g_diff + (sub_green * (1.0 - g_diff));
	float sb = f_blue * b_diff + (sub_blue * (1.0 - b_diff));

	float br = f_red * r_diff + (b_red * (1.0 - r_diff));
	float bg = f_green * g_diff + (b_green * (1.0 - g_diff));
	float bb = f_blue * b_diff + (b_blue * (1.0 - b_diff));

	base *= subPixel(sr, sg, sb, br, bg, bb);
	base += vFill(back, next, sr, sb);

	r_diff = (1.0 - max(abs(up.r - up_back.r), abs(up.r - up_next.r))) * reducer;
	g_diff = (1.0 - max(abs(up.g - up_back.g), abs(up.g - up_next.g))) * reducer;
	b_diff = (1.0 - max(abs(up.b - up_back.b), abs(up.b - up_next.b))) * reducer;

	sr = f_red * r_diff + (sub_red * (1.0 - r_diff));
	sg = f_green * g_diff + (sub_green * (1.0 - g_diff));
	sb = f_blue * b_diff + (sub_blue * (1.0 - b_diff));

	br = f_red * r_diff + (b_red * (1.0 - r_diff));
	bg = f_green * g_diff + (b_green * (1.0 - g_diff));
	bb = f_blue * b_diff + (b_blue * (1.0 - b_diff));

	up *= subPixel(sr, sg, sb, br, bg, bb);
	up += vFill(up_back, up_next, sr, sb);


	base *= hBar(base, up);

	FragColor = vec4(base, 1.0);
}
#endif
