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
	
	manipTriangle_gs4x.glsl
	Manipulate a single input triangle.
*/

/*
This file was modified by John Imgrund with permission of the author.
*/

#version 410

// ****TO-DO: 
//	1) declare input and output varying data
//	2) either copy input directly to output for each vertex, or 
//		do something with the vertices first (e.g. explode, invert)

layout (triangles) in;
layout (triangle_strip, max_vertices = 3) out;

//Set varying blocks in/out
in vDataBlock
{
	vec2 vTexCoord;
	vec4 vPosition;
	vec3 vNormal;
} vDataIn[];

out vDataBlock
{
	vec2 vTexCoord;
	vec4 vPosition;
	vec3 vNormal;
} vDataOut;

uniform mat4 uP;

void main()
{
	int objectVertices = 3;
	for(int i = 0; i < objectVertices; ++i)
	{
		vDataOut.vTexCoord = vDataIn[i].vTexCoord;
		vDataOut.vPosition = vDataIn[i].vPosition;
		vDataOut.vNormal = vDataIn[i].vNormal;

		//This line makes the objects chonky boiz (Explode/bloat)
		//vDataOut.vPosition = vDataIn[i].vPosition + vec4((normalize(vDataIn[i].vNormal) * 0.25),1);
		
		
		gl_Position = uP * vDataOut.vPosition;

		EmitVertex();
	}

	EndPrimitive();
}
