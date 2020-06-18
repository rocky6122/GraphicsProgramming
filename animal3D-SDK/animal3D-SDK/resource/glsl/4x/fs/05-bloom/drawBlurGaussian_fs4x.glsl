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
	
	drawBlurGaussian_fs4x.glsl
	Implements and performs Gaussian blur algorithms.
*/

/*
This file was modified by John Imgrund with permission of the author.
*/

#version 410

// ****TO-DO: 
//	1) declare uniforms used in this algorithm (see blur pass in render)
//	2) implement one or more 1D Gaussian blur functions
//	3) output result as blurred image

in vec2 vTexCoord;

uniform sampler2D uImage0;
uniform vec2 uPixelSz;

layout (location = 0) out vec4 rtFragColor;


// Gaussian blur with 1D kernel about given axis
//	weights are selected by rows in Pascal's triangle
//		2^0 = 1:		1
//		2^1 = 2:		1	1
//		2^2 = 4:		1	2	1
//		2^3 = 8:		1	3	3	1
//		2^4 = 16:		1	4	6	4	1

int kernel[5] = int[5](1, 4, 6, 4, 1); 

vec4 calcGaussianBlur1D_4(in sampler2D image, in vec2 center, in vec2 axis)	// (2)
{
	vec4 outputBlur;
	vec4 color = vec4(0.0);

//	for(int i = 0; i < 5; ++i)
//		{
//        	color += texture2D(image, vec2(center + axis)) * kernel[i];
//		}

	//blur using pascals triangle kernel
	color += texture(image, vec2(center + axis)) * kernel[0];
	color += texture(image, vec2(center + axis)) * kernel[1];
	color += texture(image, vec2(center)) * kernel[2];
	color += texture(image, vec2(center - axis)) * kernel[3];
	color += texture(image, vec2(center - axis)) * kernel[4];

	// dummy: sample image at center
	//return texture(image, center);

	//Divide by 1/16 for the kernel
	outputBlur = color * 0.0625;

	return outputBlur;
}


void main()
{
	//Blur
	rtFragColor = calcGaussianBlur1D_4(uImage0, vTexCoord, uPixelSz);
}
