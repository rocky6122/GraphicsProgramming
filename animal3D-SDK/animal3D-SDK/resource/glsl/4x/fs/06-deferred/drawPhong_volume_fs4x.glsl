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
	
	drawPhong_volume_fs4x.glsl
	Perform Phong shading for a single light within a volume; output 
		components to MRT.
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
//	2) declare varyings for light volume geometry
//		-> biased clip-space position, index
//	3) declare uniform blocks
//		-> implement data structure matching data in renderer
//		-> replace old lighting uniforms with new block
//	4) declare multiple render targets
//		-> diffuse lighting, specular lighting
//	5) compute screen-space coordinate for current light
//	6) retrieve new geometric inputs (no longer from varyings)
//		-> *test by outputting as color
//	7) use new inputs where appropriate in lighting
//		-> remove anything that can be deferred further

layout (location = 0) out vec4 rtFragDiffuse;
layout (location = 1) out vec4 rtFragSpecular;

//varyings
flat in int vInstanceID;
in vec4 biasClipSpace;

//Create BiasTexCoord
vec2 biasCoord = vec2(biasClipSpace.x/biasClipSpace.w, biasClipSpace.y/biasClipSpace.w);

//Structs
struct PointLight
{
	vec4 worldPos;					// position in world space
	vec4 viewPos;					// position in viewer space
	vec4 color;						// RGB color with padding
	float radius;					// radius (distance of effect from center)
	float radiusInvSq;				// radius inverse squared (attenuation factor)
	float pad[2];					// padding
};

const int MAX_LIGHTS = 1024; 

//uniform blocks

uniform ubTransformMVP{
	mat4 uMVP[MAX_LIGHTS];
};

uniform ubTransformMVPB{
	mat4 uMVPB[MAX_LIGHTS];
};

uniform ubPointLight{
	PointLight uPointLight[MAX_LIGHTS];
};

//Diffuse + Specular Maps
uniform sampler2D uTex_dm;
uniform sampler2D uTex_sm;

//G Buffers
uniform sampler2D uImage4;//position attributes
uniform sampler2D uImage5;//normal attributes
uniform sampler2D uImage6;//texCoord attributes
uniform sampler2D uImage7;//depth attributes

//Geometry Data
vec4 gPosition = texture(uImage4, biasCoord);		
vec4 gNormal = texture(uImage5, biasCoord);			
vec2 gTexCoord = texture(uImage6, biasCoord).xy;		

vec4 gDiffuse = texture(uTex_dm, gTexCoord); 
vec4 gSpecular = texture(uTex_sm, gTexCoord);


float getAttenuation(vec3 dist)
{
return clamp (10 / length(dist), 0.0, 1.0);
}

vec4 getDiffuse(int index)
{
	//Calculate the normal in view space (done in vs shader)
	vec3 N = gNormal.xyz;

	//Calculate the view-space light vector
	vec3 L = uPointLight[index].worldPos.xyz - gPosition.xyz;

	//Normalize all the vectors
	N = normalize(N);
	L = normalize(L);

	//Calculate R by reflecting -L around the plane defined by N
	vec3 R = reflect(-L, N);

	//Calculate the attenuation then get the diffuse and specular vectors (As seen in book)
	float attenuation = getAttenuation(uPointLight[index].worldPos.xyz);
	vec3 diffuse = attenuation * uPointLight[index].color.xyz * max(dot(N, L), 0.0);

	float lightDistance = smoothstep(uPointLight[index].radius, 0, distance(uPointLight[index].viewPos, gPosition));

	//Multiply this into the specular to correct it
	diffuse *= lightDistance;

	return vec4(diffuse, 1);
}

vec4 getSpecular(int index)
{
//Calculate the normal in view space (done in vs shader)
	vec3 N = gNormal.xyz;

	//Calculate the view-space light vector
	vec3 L = uPointLight[index].viewPos.xyz - gPosition.xyz;

	//calculate view vector(negative of the view space position)
	vec3 V = -gPosition.xyz;

	//Normalize all the vectors
	N = normalize(N);
	L = normalize(L);
	V = normalize(V);

	//Calculate R by reflecting -L around the plane defined by N
	vec3 R = reflect(-L, N);

	//Used to soften the specular light
	float specularPower = 16;

	vec3 specular = pow(max(dot(R, V), 0.0), specularPower) * uPointLight[index].color.xyz;

	float lightDistance = smoothstep(uPointLight[index].radius, 0, distance(uPointLight[index].viewPos, gPosition));

	//Multiply this into the specular to correct it
	specular *= lightDistance;

	//return the final color
	return vec4(specular, 1);
}

void main()
{
	//Calculate Diffuse
	rtFragDiffuse = getDiffuse(vInstanceID);

	//Calculate Specular
	rtFragSpecular = getSpecular(vInstanceID);
}

