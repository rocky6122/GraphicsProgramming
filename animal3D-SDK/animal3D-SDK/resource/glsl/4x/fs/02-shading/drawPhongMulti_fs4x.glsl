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
	
	drawPhongMulti_fs4x.glsl
	Calculate and output Phong shading model for multiple lights using data 
		from prior shader.
*/

/*
This file was modified by John Imgrund with permission of the author.
*/

#version 410

// ****TO-DO: 
//	1) declare varyings to read from vertex shader
//		-> *test all varyings by outputting them as color
//	2) declare uniforms for textures (diffuse, specular)
//	3) sample textures and store as temporary values
//		-> *test all textures by outputting samples
//	4) declare fixed-sized arrays for lighting values and other related values
//		-> *test lighting values by outputting them as color
//		-> one day this will be made easier... soon, soon...
//	5) implement Phong shading calculations
//		-> *save time where applicable
//		-> diffuse, specular, attenuation
//		-> remember to be modular (e.g. write a function)
//	6) calculate Phong shading model for one light
//		-> *test shading values (diffuse, specular) by outputting them as color
//	7) calculate Phong shading for all lights
//		-> *test shading values
//	8) add all light values appropriately
//	9) calculate final Phong model (with textures) and copy to output
//		-> *test the individual shading totals
//		-> use alpha channel from diffuse sample for final alpha

in vDataBlock
{
	vec2 vTexCoord;
	vec4 vPosition;
	vec3 vNormal;
} vDataIn;

uniform int uLightCt;
uniform vec4[4] uLightPos;
uniform vec4[4] uLightCol;
uniform float[4] uLightSz;

uniform sampler2D uTex_dm;
uniform sampler2D uTex_sm;

out vec4 rtFragColor;

float getAttenuation(vec3 dist)
{
return clamp (10 / length(dist), 0.0, 1.0);
}

vec4 getLight(int index)
{
	//Calculate the normal in view space (done in vs shader)
	vec3 N = vDataIn.vNormal;

	//Calculate the view-space light vector
	vec3 L = uLightPos[index].xyz - vDataIn.vPosition.xyz;

	//calculate view vector(negative of the view space position)
	vec3 V = -vDataIn.vPosition.xyz;

	//Normalize all the vectors
	N = normalize(N);
	L = normalize(L);
	V = normalize(V);

	//Calculate R by reflecting -L around the plane defined by N
	vec3 R = reflect(-L, N);

	//Used to soften the specular light
	float specularPower = 16;

	//Calculate the attenuation then get the diffuse and specular vectors (As seen in book)
	float attenuation = getAttenuation(uLightPos[index].xyz);
	vec3 diffuse = attenuation * uLightCol[index].xyz * max(dot(N, L), 0.0);
	vec3 specular = pow(max(dot(R, V), 0.0), specularPower) * uLightCol[index].xyz;

	//Book says this is the vector of ambient light
	vec3 ambient = vec3(0.05, 0.05, 0.05);

	//return the final color
	return vec4(ambient + specular + diffuse, 1);
}



void main()
{
	//Calculates the final light levels based on every light in the scene	
	for(int i = 0; i < uLightCt; ++i)
	{
		rtFragColor += getLight(i);
	}

	//Adds the the diffuse texturing to the objects
	rtFragColor *= texture2D(uTex_dm, vDataIn.vTexCoord); 
	
	//I would like to add the specular map texture but it does not help the output
	// to look correct
	//rtFragColor *= texture2D(uTex_sm, vTexCoord);
}
