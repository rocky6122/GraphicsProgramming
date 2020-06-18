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
	
	passBiasClipCoord_transform_instanced_vs4x.glsl
	Transform position attribute for rasterization and pass biased clip; use 
		instancing to draw multiple objects.
*/

/*
This file was modified by John Imgrund with permission of the author.
*/

#version 410

// ****TO-DO: 
//	1) declare uniform blocks
//		-> transformations
//	2) declare varyings for info to be passed to FS
//		-> biased clip-space position, index
//	3) transform input position appropriately
//	4) write to outputs

layout (location = 0) in vec4 aPosition;

const int MAX_LIGHTS = 1024;

//uniform blocks

uniform ubTransformMVP{
	mat4 uMVP[MAX_LIGHTS];
};

uniform ubTransformMVPB{
	mat4 uMVPB[MAX_LIGHTS];
};


//varyings
flat out int vInstanceID;
out vec4 biasClipSpace;

void main()
{
	//Set varyings
	vInstanceID = gl_InstanceID;

	biasClipSpace = uMVPB[vInstanceID] * aPosition;

	//Final Output
	gl_Position = uMVP[vInstanceID] * aPosition;
}
