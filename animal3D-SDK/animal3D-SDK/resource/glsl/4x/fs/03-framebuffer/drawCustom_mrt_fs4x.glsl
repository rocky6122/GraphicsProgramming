/*
	Copyright 2011-2019 Daniel S. Buckstein

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
*/

/*
	animal3D SDK: Minimal 3D Animation Framework
	By Daniel S. Buckstein
	
	drawCustom_fs4x.glsl
	Custom effects for MRT.
*/

/*
This file was modified by John Imgrund with permission of the author.
*/

#version 410

// ****TO-DO: 
//	0) copy entirety of other fragment shader to start, or start from scratch: 
//		-> declare varyings to read from vertex shader
//		-> *test all varyings by outputting them as color
//	1) declare at least four render targets
//	2) implement four custom effects, outputting each one to a render target

out vec4 rtFragColor;
layout (location = 0) out vec4 rtHeatMap;
layout (location = 1) out vec4 rtSepia;
layout (location = 2) out vec4 rtGradient;
layout (location = 3) out vec4 rtGreyScale;

//Varyings incoming from Phong Vertex Shader
in vec2 vTexCoord;
in vec4 vPosition;
in vec3 vNormal;

//Uniform color
uniform vec4 uColor;

//Lighting info
uniform int uLightCt;
uniform vec4[4] uLightPos;
uniform vec4[4] uLightCol;
uniform float[4] uLightSz;

//Texture Maps
uniform sampler2D uTex_dm;
uniform sampler2D uTex_sm;

vec4 greyScaleShader()
{
	vec3 color = texture2D(uTex_dm, vTexCoord).rgb;
    float grey = (color.r + color.g + color.b) / 3.0;
    vec3 greyScale = vec3(grey);

	return vec4(greyScale, 1);
}

vec4 sepiaShader(float r, float g, float b)
{
	float outputRed = (r * .393) + (g *.769) + (b * .189);
	float outputGreen = (r * .349) + (g *.686) + (b * .168);
	float outputBlue = (r * .272) + (g *.534) + (b * .131);

	return vec4(outputRed, outputGreen, outputBlue, 1);
}

vec4 gradientShader(vec3 color1, vec3 color2)
{
	vec2 st = gl_FragCoord.xy / vec2(1920, 1080);

  float mixValue = distance(st,vec2(0,.8));
  vec3 color = mix(color1,color2,mixValue);

  return vec4(color, 1);
}

//Provided by https://gist.github.com/eladg/522baa6d9101b828539d4ed1b194891e
float fade(float low, float high, float value){
    float mid = (low+high)*0.5;
    float range = (high-low)*0.5;
    float x = 1.0 - clamp(abs(mid-value)/range, 0.0, 1.0);
    return smoothstep(0.0, 1.0, x);
}

//Provided by https://gist.github.com/eladg/522baa6d9101b828539d4ed1b194891e
vec3 getColor(float intensity){
    vec3 blue = vec3(0.0, 0.0, 1.0);
    vec3 cyan = vec3(0.0, 1.0, 1.0);
    vec3 green = vec3(0.0, 1.0, 0.0);
    vec3 yellow = vec3(1.0, 1.0, 0.0);
    vec3 red = vec3(1.0, 0.0, 0.0);

    vec3 color = (
        fade(-0.25, 0.25, intensity)*blue +
        fade(0.0, 0.5, intensity)*cyan +
        fade(0.25, 0.75, intensity)*green +
        fade(0.5, 1.0, intensity)*yellow +
        smoothstep(0.75, 1.0, intensity)*red
    );
    return color;
}

vec4 heatMapShader()
{
	float intensity = smoothstep(0, 1, texture2D(uTex_dm, vTexCoord).r);
	vec3 color = getColor(intensity);

	float alpha = smoothstep(0, 1, intensity);
    return vec4(color*alpha, alpha);
}


void main()
{
 //Heat Map Shader. Provided by https://gist.github.com/eladg/522baa6d9101b828539d4ed1b194891e
 rtHeatMap = heatMapShader();

 //Sepia Shader. Numbers for rgb conversion provided by https://www.techrepublic.com/blog/how-do-i/how-do-i-convert-images-to-grayscale-and-sepia-tone-using-c/
 vec4 texColors = texture2D(uTex_dm, vTexCoord);
 rtSepia = sepiaShader(texColors.x, texColors.y, texColors.z);

 //Take any two colors and mix them together for a gradient
 rtGradient = gradientShader(vec3(1,1,0), vec3(0,0,1));

 //GreyScale Shader
 rtGreyScale = greyScaleShader();
}
