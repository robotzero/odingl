#version 330 core

layout (location = 0) in vec3 Position;
uniform mat4 gTranslation;

void main()
{
    //gl_Position = vec4(Position.x, Position.y, Position.z, 1.0);
    gl_Position = gTranslation * vec4(Position, 1.0);
}