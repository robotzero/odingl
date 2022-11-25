#version 330 core

layout (location = 0) in vec3 Position;
uniform mat4 gWVP;

void main()
{
    //gl_Position = gTranslation * gRotation * vec4(Position, 1.0);
    // gl_Position = gRotation * vec4(Position, 1.0);
    gl_Position = gWVP * vec4(Position, 1.0);
    Color = vec4(clamp(Position, 0.0, 1.0), 1.0);
}