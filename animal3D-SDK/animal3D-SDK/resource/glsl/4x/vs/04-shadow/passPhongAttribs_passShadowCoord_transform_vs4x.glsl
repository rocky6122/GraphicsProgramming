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
	
	passPhongAttribs_passShadowCoord_transform_vs4x.glsl
	Transform position attribute for rasterization and shadow coordinate; pass 
		attributes related to Phong and projection.
*/

/*
This file was modified by John Imgrund with permission of the author.
*/

#version 410

// ****TO-DO: 
//	0) copy entirety of Phong vertex shader CHECK
//	1) declare uniform for projector transform CHECK
//	2) declare varying for shadow coordinate CHECK
//	3) calculate and copy shadow coordinate CHECK

uniform mat4 uMV;
uniform mat4 uP;
uniform mat3 uMV_nrm;
uniform mat4 uMVPB_proj; //I think this is the right projector

layout (location = 0) in vec4 aPosition;
layout (location = 2) in vec3 aNormal;
layout (location = 8) in vec2 aTexCoord;

//Varyings
out vec2 vTexCoord;
out vec4 vPosition;
out vec3 vNormal;
out vec4 vShadowCoord;

void main()
{	
	//Assign Varyings
	vTexCoord = aTexCoord;
	vPosition = uMV * aPosition;
	vShadowCoord = uMVPB_proj * aPosition;

	// Transform object-space normal to eye space
	//Here I would like to use uMV_nrm, as I believe this is where it should be used,
	//but using it keeps blanking all textures. The book recommended this instead.
	vNormal = mat3(uMV) * aNormal;

	// Transform object-space to eye space to clip space
	gl_Position = uP * (uMV * aPosition);
}
