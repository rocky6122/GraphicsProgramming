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
	
	drawBrightPass_fs4x.glsl
	Perform bright pass filter: bright stays bright, dark gets darker.
*/

/*
This file was modified by John Imgrund with permission of the author.
*/

#version 410

// ****TO-DO: 
//	1) implement a function to calculate the relative luminance of a color
//	2) implement a general tone-mapping or bright-pass filter
//	3) sample the input texture
//	4) filter bright areas, output result

in vec2 vTexCoord;

uniform sampler2D uImage0;

layout (location = 0) out vec4 rtFragColor;
layout (location = 1) out vec4 rtBrightColor;

//relative luminance
float calcLuminance(float r, float g, float b)
{
	float luminance = dot(vec3(r,g,b), vec3(0.2126, 0.7152, 0.0722));

	return luminance;
}

//Tone Mapping
vec3 reinhardToneMap(vec3 hdrColor, float gamma)
{
	//Gamma
	//float gamma = 2.2;

	//Map the reinhard tone map
	vec3 mapped = hdrColor / (hdrColor + vec3(1.0));

	//gamma correction
	mapped = pow(mapped, vec3(1.0 / gamma));

	return mapped;
}


void main()
{
	// Grab HDR texture
	vec4 hdrColor = texture(uImage0, vTexCoord);

	//Add in sampled HDR texture
	rtFragColor = hdrColor;

	//Calculate the brightness of each pixel
	float brightness = calcLuminance(rtFragColor.r, rtFragColor.g, rtFragColor.b);

	////Multiply in the luminance function
	rtFragColor *= brightness;
	
	//Add the tone map
	rtFragColor += vec4(reinhardToneMap(hdrColor.xyz, brightness), 1.0);
}
