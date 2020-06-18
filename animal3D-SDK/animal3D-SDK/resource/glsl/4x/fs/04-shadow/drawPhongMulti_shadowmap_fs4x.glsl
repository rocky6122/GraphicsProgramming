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
	
	drawPhongMulti_shadowmap_fs4x.glsl
	Phong shading with shadow mapping.
*/

#version 410

// ****TO-DO: 
//	0) copy entirety of Phong fragment shader CHECK
//	1) declare shadow map texture CHECK
//	2) declare varying to receive shadow coordinate CHECK
//	3) perform perspective divide to acquire projector's screen-space coordinate
//		-> *try outputting this as color
//	4) sample shadow map using screen-space coordinate
//		-> *try outputting this on its own
//	5) perform shadow test
//		-> *try outputting result (boolean)
//	6) apply shadow to shading model

in vec2 vTexCoord;
in vec4 vPosition;
in vec3 vNormal;
in vec4 vShadowCoord;

uniform int uLightCt;
uniform vec4[4] uLightPos;
uniform vec4[4] uLightCol;
uniform float[4] uLightSz;

uniform sampler2D uTex_dm;
uniform sampler2D uTex_sm;
uniform sampler2D uTex_shadow;

out vec4 rtFragColor;

float getAttenuation(vec3 dist)
{
return clamp (10 / length(dist), 0.0, 1.0);
}

float calcShadow()
{
//Pre-serialized perspective divivde
	vec4 projScreen = vShadowCoord / vShadowCoord.w;

	//calc Shadows just the red value
	float shadowValue = texture2D(uTex_shadow, projScreen.xy).r;

	//Changes fragShadow depending on (projScreen.z > (shadowValue) + 0.0025)
	float fragShadow = (projScreen.z > shadowValue + 0.0025) ? 0.2 : 1;

	return fragShadow;
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

	diffuse *= calcShadow();

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

	//Adds textures
	rtFragColor *= texture2D(uTex_dm, vTexCoord); 

	//--END OF PHONG SHADING--
}
