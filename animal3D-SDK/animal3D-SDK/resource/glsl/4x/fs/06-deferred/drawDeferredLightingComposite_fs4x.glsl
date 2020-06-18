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
	
	drawDeferredLightingComposite_fs4x.glsl
	Composite deferred lighting.
*/

/*
This file was modified by John Imgrund with permission of the author.
*/

#version 410

// ****TO-DO: 
//	1) declare images with results of lighting pass
//	2) declare remaining geometry inputs (atlas coordinates) and atlas textures
//	3) declare any other shading variables not involved in lighting pass
//	4) sample inputs to get components of Phong shading model
//		-> surface colors, lighting results
//		-> *test by outputting as color
//	5) compute final Phong shading model (i.e. the final sum)

in vec2 vTexCoord;

layout (location = 0) out vec4 rtFragColor;

//G Buffers
uniform sampler2D uImage4;//Diffuse attributes
uniform sampler2D uImage5;//Specular attributes
uniform sampler2D uImage6;//texCoord attributes
uniform sampler2D uImage7;//depth attributes

//Uniforms
uniform sampler2D tex_atlas_dm;

//Geometry Data
vec4 gDiffuse = texture(uImage4, vTexCoord);		
vec4 gSpecular = texture(uImage5, vTexCoord);			
vec2 gTexCoord = texture(uImage6, vTexCoord).xy;	

vec4 gDiffuseAtlas = texture(tex_atlas_dm, gTexCoord); 

void main()
{
	//Just like adding the phong shaders together
	vec3 specFinal = gSpecular.xyz;
	vec3 diffFinal = gDiffuse.xyz;

	vec3 ambient = vec3(.05, .05, .05);

	rtFragColor = vec4(specFinal + diffFinal + ambient, 1) * gDiffuseAtlas;
}
