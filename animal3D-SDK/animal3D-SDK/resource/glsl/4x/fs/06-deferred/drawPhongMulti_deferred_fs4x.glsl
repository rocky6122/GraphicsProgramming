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
	
	drawPhongMulti_deferred_fs4x.glsl
	Perform Phong shading on multiple lights, deferred.
*/

/*
This file was modified by John Imgrund with permission of the author.
*/

#version 410

// ****TO-DO: 
//	0) copy entirety of Phong multi-light shader
//	1) geometric inputs from scene objects are not received from VS!
//		-> we are drawing a textured FSQ so where does the geometric 
//			input data come from? declare appropriately
//	2) retrieve new geometric inputs (no longer from varyings)
//		-> *test by outputting as color
//	3) use new inputs where appropriate in lighting

//Varyings
in vec2 vTexCoord;

//Lights
uniform int uLightCt;
uniform vec4[4] uLightPos;
uniform vec4[4] uLightCol;
uniform float[4] uLightSz;

//Diffuse + Specular Maps
uniform sampler2D uTex_dm;
uniform sampler2D uTex_sm;

//G Buffers
uniform sampler2D uImage4;//position attributes
uniform sampler2D uImage5;//normal attributes
uniform sampler2D uImage6;//texCoord attributes
uniform sampler2D uImage7;//depth attributes

//Geometry Data
vec4 gPosition = texture(uImage4, vTexCoord);		
vec4 gNormal = texture(uImage5, vTexCoord);			
vec2 gTexCoord = texture(uImage6, vTexCoord).xy;		

vec4 gDiffuse = texture(uTex_dm, gTexCoord); 
vec4 gSpecular = texture(uTex_sm, gTexCoord);

out vec4 rtFragColor;

float getAttenuation(vec3 dist)
{
return clamp (10 / length(dist), 0.0, 1.0);
}

//Used to soften the specular light
float specularPower = 16;

vec4 getLight(int index)
{
	//Calculate the normal in view space (done in vs shader)
	vec3 N = gNormal.xyz;

	//Calculate the view-space light vector
	vec3 L = uLightPos[index].xyz - gPosition.xyz;

	//calculate view vector(negative of the view space position)
	vec3 V = -gPosition.xyz;

	//Normalize all the vectors
	N = normalize(N);
	L = normalize(L);
	V = normalize(V);

	//Calculate R by reflecting -L around the plane defined by N
	vec3 R = reflect(-L, N);

	//Calculate the attenuation then get the diffuse and specular vectors (As seen in book)
	float attenuation = getAttenuation(uLightPos[index].xyz);

	vec3 diffuse = attenuation * max(dot(N, L), 0.0) * uLightCol[index].xyz;

	vec3 specular = pow(max(dot(R, V), 0.0), specularPower) * uLightCol[index].xyz;

	//Book says this is the vector of ambient light
	vec3 ambient = vec3(0.05, 0.05, 0.05);

	vec3 diffSpec = diffuse + specular;

	//return the final color
	return vec4(diffSpec + ambient, 1);
}

void main()
{
	//Calculates the final light levels based on every light in the scene	
	for(int i = 0; i < uLightCt; ++i)
	{
		rtFragColor += getLight(i);
	}

	//Adds the the diffuse texturing to the objects
	rtFragColor *= gDiffuse; 
}