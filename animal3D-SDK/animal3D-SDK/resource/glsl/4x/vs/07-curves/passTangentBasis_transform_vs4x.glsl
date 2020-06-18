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
	
	passTangentBasis_transform_vs4x.glsl
	Transform and pass complete tangent basis.
*/

/*
This file was modified by John Imgrund with permission of the author.
*/

#version 410

// ****TO-DO: 
//	1) declare remaining tangent basis attributes
//	2) declare transformation matrix uniforms
//	3) declare tangent basis to pass along
//	4) define local tangent basis
//	5) transform and pass tangent basis
//	6) set final clip-space position

layout (location = 0) in vec4 aPosition;
layout (location = 2) in vec3 aNormal;
layout (location = 10) in vec3 aTangent;
layout (location = 11) in vec3 aBiTangent;

//Declare uniforms
uniform mat4 uMV;
uniform mat4 uP;

//Varyings
out mat4 vTangentBasis;

void main()
{
	//Create the TangentBasis
	mat4 tangentBasis = mat4(
	aTangent, 0,
	aBiTangent, 0,
	aNormal, 0,
	aPosition
	);

	//Place into object space
	vTangentBasis = uMV * tangentBasis;

	gl_Position = uP * vTangentBasis[3];
}
