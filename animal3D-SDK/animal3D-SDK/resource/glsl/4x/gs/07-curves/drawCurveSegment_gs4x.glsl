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
	
	drawCurveSegment_gs4x.glsl
	Draw curve segment using interpolation algorithm.
*/

/*
This file was modified by John Imgrund with permission of the author.
*/

#version 410

// ****TO-DO: 
//	1) declare input varying data
//	2) declare uniform blocks
//	3) implement interpolation sampling function(s)
//	4) implement curve drawing function(s)
//	5) call choice curve drawing function in main

#define max_verts 32
#define max_waypoints 32

layout (points) in;
layout (line_strip, max_vertices = max_verts) out;

//Varyings
flat in int vPassInstanceID[];

in VS_OUT {
	vec3 color;
	int curveType;
} gs_in[];

//out varyings
out vec3 fColor;

//uniforms
uniform mat4 uMVP;

//Uniform Blocks
uniform ubCurveWaypoint
{
	vec4 vCurveWayPoint[max_waypoints];
} uWayPoint;

uniform ubCurveHandle
{
	vec4 vCurveHandle[max_verts];
} uHandle;

//catmullRom Taken from the Slides https://champlain.instructure.com/courses/1051898/files/74056100?module_item_id=26282072
//Slide 91

//Catmull-Rom
vec4 catmullRom(vec4 pointN1, vec4 point0, vec4 point1, vec4 point2, float control)
{
	//Calculate P -1
	vec4 pN1 = (-control + 2 * pow(control, 2) - pow(control, 3)) * pointN1;

	//Calculate P0
	vec4 p0 = (2 - 5 * pow(control, 2) + 3 * pow(control, 3)) * point0;

	//Calculate P1
	vec4 p1 = (control + 4 * pow(control, 2) - 3 * pow(control, 3)) * point1;

	//Calculate P2
	vec4 p2 = (-pow(control, 2) + pow(control, 3)) * point2;

	//Final
	return .5 * (pN1 + p0 + p1 + p2);
}

//Cubic Hermite
vec4 CubicHermite(vec4 pointN1, vec4 point0, vec4 point1, vec4 point2, float control)
{
	vec4 basis00 = ((1 + 2 * control) * ((1 - control) * (1 - control))) * pointN1;

	vec4 basis10 = (control * ((1 - control) * (1 - control))) * point0;

	vec4 basis01 = ((control * control) * (3 - 2 * control)) * point1;

	vec4 basis11 = ((control * control) * (control - 1)) * point2;

	return basis00 + basis10 + basis01 + basis11;
}


void main()
{
	int index = vPassInstanceID[0]; 
	fColor = gs_in[0].color;

	if(gs_in[0].curveType == 0)
	{
		//Catmull Rom drawing
		for(float i = 0; i < 1; i = i + 0.05f)
		{
			//Draw the point in the line
			vec4 point = catmullRom(uWayPoint.vCurveWayPoint[index - 1], uWayPoint.vCurveWayPoint[index], uWayPoint.vCurveWayPoint[index + 1], uWayPoint.vCurveWayPoint[index + 2], i);

			//Add it into the line
			gl_Position = uMVP * point;

			//Push vertex into the line
			EmitVertex();
		}

		//End Line
		EndPrimitive();
	}
	else
	{
		//Cubic Hermit drawing
		for(float i = 0; i < 1; i = i + 0.05f)
		{
			//Draw the point in the line
			vec4 point = CubicHermite(uWayPoint.vCurveWayPoint[index], uHandle.vCurveHandle[index], uWayPoint.vCurveWayPoint[index + 1], uHandle.vCurveHandle[index + 1], i);

			//Add it into the line
			gl_Position = uMVP * point;

			//Push the vertex into the line
			EmitVertex();
		}

		//End Line
		EndPrimitive();
	}
}