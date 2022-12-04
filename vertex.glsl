#version 330 core

layout (location = 0) in vec3 Position;
//layout (location = 1) in vec3 Color;
out vec4 Color;
uniform mat4 gWVP;

void main()
{
    gl_Position = gWVP * vec4(Position, 1.0);
    Color = vec4(clamp(Position, 0.0, 1.0), 1.0);
}