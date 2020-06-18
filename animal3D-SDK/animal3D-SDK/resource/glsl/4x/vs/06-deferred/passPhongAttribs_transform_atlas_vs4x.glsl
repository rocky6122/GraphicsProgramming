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
	
	passPhongAttribs_transform_atlas_vs4x.glsl
	Transform position attribute and pass attributes related to Phong shading 
		model down the pipeline. Also transforms texture coordinates.
*/

/*
This file was modified by John Imgrund with permission of the author.
*/

#version 410

// ****TO-DO: 
//	1) declare transformation uniforms
//	2) declare varyings (attribute data) to send to fragment shader
//	3) transform input data appropriately
//	4) copy transformed data to varyings

layout (location = 0) in vec4 aPosition;
layout (location = 2) in vec4 aNormal;
layout (location = 8) in vec4 aTexcoord;


//Uniforms
uniform mat4 uMV;
uniform mat4 uP;
uniform mat4 uMV_nrm;
uniform mat4 uAtlas;


//Varyings
out vec4 vPosition;
out vec4 vNormal;
out vec4 vAtlas;



void main()
{
	//Set varyings
	vPosition = uMV * aPosition;

	vNormal = normalize(uMV_nrm * aNormal);

	vAtlas = uAtlas * aTexcoord;


	//Transform object-space to eye space to clip space
	vec4 clipSpace = uP * (uMV * aPosition);

	//Final output
	gl_Position = clipSpace;
}
