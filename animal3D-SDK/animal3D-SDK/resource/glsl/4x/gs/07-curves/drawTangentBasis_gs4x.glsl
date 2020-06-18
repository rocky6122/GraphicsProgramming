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
	
	drawTangentBasis_gs4x.glsl
	Draw tangent basis.
*/

/*
This file was modified by John Imgrund with permission of the author.
*/

#version 410

// ****TO-DO: 
//	1) declare input and output varying data
//	2) draw tangent basis in place of each vertex

layout (triangles) in;
layout (line_strip, max_vertices = 18) out;

//Varyings in/out
in mat4 vTangentBasis[];

out vec4 vPassColor;

uniform mat4 uP;

mat4 color = mat4(
	1, 0, 0, 1,
	0, 1, 0, 1,
	0, 0, 1, 1,
	0, 0, 0, 1
);

void main()
{
	int objectVertices = 3;
	int colorCount = 3;
	float depth = 0.15;

	for(int i = 0; i < objectVertices; ++i)
	{
		for(int j = 0; j < colorCount; ++j)
		{
			//Select Color
			vPassColor = color[j];

			gl_Position = uP * vTangentBasis[i][3];
			EmitVertex();

			//Create offset
			vec4 biasOffest = uP * (normalize(vTangentBasis[i][j]) * depth);

			gl_Position = uP * vTangentBasis[i][3] + biasOffest;
			EmitVertex();
		}

		EndPrimitive();
	}
}
