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
	
	drawPhongMulti_mrt_fs4x.glsl
	Phong shading model with splitting to multiple render targets (MRT).
*/

/*
This file was modified by John Imgrund with permission of the author.
*/

#version 410

// ****TO-DO: 
//	0) copy entirety of Phong fragment shader
//	1) declare eight render targets
//	2) output appropriate data to render targets

//Create 8 render targets
layout (location = 0) out vec4 rtPosition;
layout (location = 1) out vec3 rtNormal;
layout (location = 2) out vec2 rtTexCoord;
layout (location = 3) out vec4 rtDiffuseMap;
layout (location = 4) out vec4 rtSpecularMap;
layout (location = 5) out vec4 rtDiffuseShading;
layout (location = 6) out vec4 rtSpecularShading;
layout (location = 7) out vec4 rtPhongShading;

//Varyings incoming from Phong Vertex Shader
in vec2 vTexCoord;
in vec4 vPosition;
in vec3 vNormal;

//Lighting info
uniform int uLightCt;
uniform vec4[4] uLightPos;
uniform vec4[4] uLightCol;
uniform float[4] uLightSz;

//Texture Maps
uniform sampler2D uTex_dm;
uniform sampler2D uTex_sm;

float getAttenuation(vec3 dist)
{
return clamp (10 / length(dist), 0.0, 1.0);
}

vec4 getLight(int index)
{
	//Calculate the normal in view space (done in vs shader)
	vec3 N = vNormal;

	//Calculate the view-space light vector
	vec3 L = uLightPos[index].xyz - vPosition.xyz;

	//calculate view vector(negative of the view space position)
	vec3 V = -vPosition.xyz;

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

vec4 getDiffuseShading()
{
	vec4 diffuseFinal;

	//Calculate the normal in view space (done in vs shader)
	vec3 N = vNormal;

	for(int i = 0; i < uLightCt; ++i)
	{
		vec3 L = uLightPos[i].xyz - vPosition.xyz;

	//Normalize all the vectors
	N = normalize(N);
	L = normalize(L);

	//Calculate the attenuation then get the diffuse and specular vectors (As seen in book)
	vec3 diffuse = uLightCol[i].xyz * max(dot(N, L), 0.0);

	diffuseFinal += vec4(diffuse,1);
	}

	return diffuseFinal;
}

vec4 getSpecularShading()
{
	vec4 specularFinal;

	//Calculate the normal in view space (done in vs shader)
	vec3 N = vNormal;

	for(int i = 0; i < uLightCt; ++i)
	{
	//Calculate the view-space light vector
	vec3 L = uLightPos[i].xyz - vPosition.xyz;

	//calculate view vector(negative of the view space position)
	vec3 V = -vPosition.xyz;

	//Normalize all the vectors
	N = normalize(N);
	L = normalize(L);
	V = normalize(V);

	//Calculate R by reflecting -L around the plane defined by N
	vec3 R = reflect(-L, N);

	//Used to soften the specular light
	float specularPower = 16;

	//Calculate Specular
	vec3 specular = pow(max(dot(R, V), 0.0), specularPower) * uLightCol[i].xyz;

	specularFinal += vec4(specular,1);
	}
	//return the final color
	return specularFinal;
}

vec4 getPhongFinal()
{
	vec4 tempPhong;

	//Calculates the final light levels based on every light in the scene	
	for(int i = 0; i < uLightCt; ++i)
	{
		tempPhong += getLight(i);
	}

	//Add texturing
	tempPhong *= texture2D(uTex_dm, vTexCoord); 

	return tempPhong;
}

void main()
{
	//Output each value as color to each layout
	rtPosition = vPosition;
	rtNormal = normalize(vNormal);
	rtTexCoord = vTexCoord;
	rtDiffuseMap = texture2D(uTex_dm, vTexCoord);
	rtSpecularMap = texture2D(uTex_sm, vTexCoord);
	rtDiffuseShading = getDiffuseShading();
	rtSpecularShading = getSpecularShading();
	rtPhongShading = getPhongFinal();
}