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
	
	drawCustom_post_fs4x.glsl
	Custom post-processing fragment shader.
*/

#version 410

// ****TO-DO: 
//	0) start with texturing FS
//	1) declare any other uniforms, textures or otherwise, that would be 
//		appropriate for some post-processing effect
//	2) implement some simple post-processing algorithm (e.g. outlines)

uniform sampler2D uTex_dm;
uniform sampler2D uTex_proj;
uniform float uTime;

in vec2 vTexCoord;
in vec3 vNormal;
in vec4 vPosition;

out vec4 rtFragColor;

float offset = cos(uTime);

void main()
{

//Found at https://en.wikibooks.org/wiki/OpenGL_Programming/Post-Processing
	vec2 texcoord = vTexCoord;
	
	texcoord.x += sin(texcoord.y * 4*2*3.14159 + offset) / 100;
	texcoord.y += sin(texcoord.x * 4*2*3.14159 + offset) /100;

	rtFragColor = texture2D(uTex_dm, texcoord);
}
