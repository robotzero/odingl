#version 330 core

in vec4 Color;
out vec4 FragColor;

void main()
{
    //FragColor = vec4(1.0, 0.0, 0.0, 1.0);
    FragColor = Color;
}