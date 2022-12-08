#version 330 core

in vec4 Color;
out vec4 FragColor;
uniform sampler2D gSampler;
in vec2 TexCoord0;

void main()
{
    //FragColor = vec4(1.0, 0.0, 0.0, 1.0);
    FragColor = texture2D(gSampler, TexCoord0);
}