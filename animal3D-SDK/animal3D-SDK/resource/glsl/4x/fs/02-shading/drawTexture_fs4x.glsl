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
	
	drawTexture_fs4x.glsl
	Draw texture sample using texture coordinate from prior shader.
*/

/*
This file was modified by John Imgrund with permission of the author.
*/

#version 410

//	1) declare varying to read texture coordinate
//		-> *test varying by outputting it as color; shows red-green gradient
//	2) declare texture uniform for diffuse map
//	3) sample texture in main
//	4) copy texture sample to output

uniform sampler2D texSample;

in vec2 vTexCoord;
out vec4 rtFragColor;

void main()
{
	// DUMMY OUTPUT: all fragments are FADED YELLOW
	//rtFragColor = vec4(1.0, 1.0, 0.5, 1.0);
	rtFragColor = texture2D(texSample, vTexCoord);
}
