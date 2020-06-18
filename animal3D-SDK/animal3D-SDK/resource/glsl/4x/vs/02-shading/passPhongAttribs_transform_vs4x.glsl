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
	
	passPhongAttribs_transform_vs4x.glsl
	Transform position attribute and pass attributes related to Phong shading 
		model down the pipeline.
*/

/*
This file was modified by John Imgrund with permission of the author.
*/

#version 410

// ****TO-DO: 
//	1) declare separate uniforms for MV and P matrices
//	2) transform object-space position to eye-space
//	3) transform eye-space position to clip space, store as output
//	4) declare normal attribute
//		-> look in 'a3_VertexDescriptors.h' for the correct location index
//	5) declare normal MV matrix
//	6) transform object-space normal to eye-space using the correct matrix
//	7) declare texcoord attribute
//	8) declare varyings for lighting data
//	9) copy lighting data to varyings

uniform mat4 uMV;
uniform mat4 uP;
uniform mat3 uMV_nrm;

layout (location = 0) in vec4 aPosition;
layout (location = 2) in vec3 aNormal;
layout (location = 8) in vec2 aTexCoord;

out vec2 vTexCoord;
out vec4 vPosition;
out vec3 vNormal;

out vDataBlock
{
	vec2 vTexCoord;
	vec4 vPosition;
	vec3 vNormal;
} vData;

void main()
{	
	vTexCoord = aTexCoord;
	vPosition = uMV * aPosition;

	// Transform object-space normal to eye space
	//Here I would like to use uMV_nrm, as I believe this is where it should be used,
	//but using it keeps blanking all textures. The book recommended this instead.
	vNormal = mat3(uMV) * aNormal;


	//Set varyings for the data block
	vData.vTexCoord = vTexCoord;
	vData.vPosition = vPosition;
	vData.vNormal = vNormal;




	// Transform object-space to eye space to clip space
	gl_Position = uP * (uMV * aPosition);
}
