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
	
	drawCurveHandles_gs4x.glsl
	Draw curve control values.
*/

/*
This file was modified by John Imgrund with permission of the author.
*/

#version 410

// ****TO-DO: 
//	1) declare input varying data
//	2) declare uniform blocks
//	3) draw line between waypoint and handle
//	4) draw shape for handle (e.g. diamond)

#define max_verts 8
#define max_waypoints 32

layout (points) in;
layout (line_strip, max_vertices = max_verts) out;

//Uniforms
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

//varyings
flat in int vPassInstanceID[];

void main()
{
	int index = vPassInstanceID[0];
	
	//Draw line
	gl_Position = uMVP * uWayPoint.vCurveWayPoint[index];
	EmitVertex();

	gl_Position = uMVP * uHandle.vCurveHandle[index];
	EmitVertex();

	EndPrimitive();

	//Draw Diamond Handle (Like connect the dots)
	gl_Position = uMVP * (uHandle.vCurveHandle[index] + vec4(.25,0,0,0));
	EmitVertex();
	gl_Position = uMVP * (uHandle.vCurveHandle[index] + vec4(0,.25,0,0));
	EmitVertex();
	gl_Position = uMVP * (uHandle.vCurveHandle[index] + vec4(-.25,0,0,0));
	EmitVertex();
	gl_Position = uMVP * (uHandle.vCurveHandle[index] + vec4(0,-.25,0,0));
	EmitVertex();
	gl_Position = uMVP * (uHandle.vCurveHandle[index] + vec4(.25,0,0,0));
	EmitVertex();

	EndPrimitive();

}
