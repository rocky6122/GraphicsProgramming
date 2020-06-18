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
	
	passInstanceID_vs4x.glsl
	Outputs raw position attribute and pass instance ID;
*/

#version 410

#define max_waypoints 32

layout (location = 0) in vec4 aPosition;

flat out int vPassInstanceID;

out VS_OUT {
	vec3 color;
	int curveType;
} vs_out;

//Uniform Blocks
uniform ubCurveType
{
	int vCurveSegments[max_waypoints];
} uCurveSegments;

uniform ubCurveSpeed
{
	int vCurveSpeed[max_waypoints];
} uCurveSpeed;

void main()
{
	vPassInstanceID = gl_InstanceID;
	gl_Position = aPosition;

	//Place curveType into the vs_out
	vs_out.curveType = uCurveSegments.vCurveSegments[vPassInstanceID];

	//Select Color based on speed (Slowest->fastest descending)
	if(uCurveSpeed.vCurveSpeed[vPassInstanceID] <= 2) //red
	{
		vs_out.color = vec3(1, 0, 0);
	}
	else if(uCurveSpeed.vCurveSpeed[vPassInstanceID] <= 4) //purple
	{
		vs_out.color = vec3(0.5, 0, 0.5);
	}
	else if(uCurveSpeed.vCurveSpeed[vPassInstanceID] <= 6) //blue
	{
		vs_out.color = vec3(0, 0, 1);	
	}
	else if(uCurveSpeed.vCurveSpeed[vPassInstanceID] <= 8) //Yellow
	{
		vs_out.color = vec3(1, 1, 0);
	}
	else //Green
	{
		vs_out.color = vec3(0, 1, 0);
	}
}
