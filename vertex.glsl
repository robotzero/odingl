#version 330 core

layout (location = 0) in vec3 Position;
//uniform mat4 gTranslation;
//uniform mat4 gRotation;
uniform mat4 gScaling;

void main()
{
    //gl_Position = gTranslation * gRotation * vec4(Position, 1.0);
    // gl_Position = gRotation * vec4(Position, 1.0);
    gl_Position = gScaling * vec4(Position, 1.0);
}