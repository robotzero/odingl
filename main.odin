package main

import "core:fmt"
import "core:math/linalg"
import "core:os"
import "core:c"
import "core:strings"
import "core:runtime"
import "core:time"
import "vendor:glfw"
import "core:math"
import gl "vendor:OpenGL"
import "math3d"
import "camera"
import "core:math/rand"

WIDTH  	:: 2560
HEIGHT 	:: 1440
// WIDTH  	:: 800
// HEIGHT 	:: 600
TITLE 	:: "Tutorial 12"
RED 	:: 0.0
GREEN	:: 0.0
BLUE	:: 0.0
ALPHA	:: 0.0
SCALE: f32 = 1.0
FOV : f32 = 45.0
zNear : f32 = 1.0
zFar : f32 = 100.0
watch            : time.Stopwatch
// @note You might need to lower this to 3.3 depending on how old your graphics card is.
GL_MAJOR_VERSION :: 4
GL_MINOR_VERSION :: 6
VBO: u32
IBO: u32
gWVPLocation: i32
projectionInfo: math3d.PersProjInfo = math3d.PersProjInfo{FOV, WIDTH, HEIGHT, zNear, zFar}
cameraPos:= linalg.Vector3f32{0.0, 0.0, -1.0}
cameraTarget:= linalg.Vector3f32{0.0, 0.0, 1.0}
cameraUp: = linalg.Vector3f32{0.0, 1.0, 0.0}
gameCamera: camera.Camera = camera.Camera{
	1.0, WIDTH, HEIGHT,
	//linalg.Vector3f32{0.0, 0.0, 0.0}, linalg.Vector3f32{0.0, 0.0, 1.0}, linalg.Vector3f32{0.0, 1.0, 0.0},
	cameraPos, cameraTarget, cameraUp,
	0, 0, false, false, false, false, linalg.Vector2f32{0.0, 0.0},
}
program: u32
vertex_shader:= string(#load("vertex.glsl"))
fragment_shader:= string(#load("fragment.glsl"))

Vertex :: struct {
	pos: linalg.Vector3f32,
	color: linalg.Vector3f32,
}

vertex :: proc(x: f32, y: f32, z: f32, using self: ^Vertex) {
	self.pos = linalg.Vector3f32{x, y, z}
	red: f32 = rand.float32()
	green: f32 = rand.float32()
	blue: f32 = rand.float32()
	self.color = linalg.Vector3f32{red, green, blue}
}

main :: proc() {
	if !bool(glfw.Init()) {
		fmt.eprintln("GLFW has failed to load.")
		return 
	}
	
	glfw.WindowHint(glfw.RESIZABLE, 1)
	glfw.WindowHint(glfw.DEPTH_BITS, 24)
	glfw.WindowHint(glfw.DOUBLEBUFFER, 1)
	glfw.WindowHint(glfw.DECORATED, 1)
	// glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, GL_MAJOR_VERSION) 
	// glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, GL_MINOR_VERSION)
	// glfw.WindowHint(glfw.OPENGL_PROFILE,glfw.OPENGL_CORE_PROFILE)

	window_handle := glfw.CreateWindow(WIDTH, HEIGHT, TITLE, glfw.GetPrimaryMonitor(), nil)

	defer glfw.Terminate()
	defer glfw.DestroyWindow(window_handle)

	if window_handle == nil {
		fmt.eprintln("GLFW has failed to load the window.")
		return
	}

	// Load OpenGL context or the "state" of OpenGL.
	glfw.SetKeyCallback(window_handle, keyboardCB)
	glfw.SetCursorPosCallback(window_handle, mouseCB)
	glfw.SetInputMode(window_handle, glfw.CURSOR, glfw.CURSOR_DISABLED)
	glfw.MakeContextCurrent(window_handle)
	glfw.SwapInterval(1)
	// Load OpenGL function pointers with the specficed OpenGL major and minor version.
	gl.load_up_to(GL_MAJOR_VERSION, GL_MINOR_VERSION, glfw.gl_set_proc_address)
	
	gl.Enable(gl.CULL_FACE)
	gl.FrontFace(gl.CW)
	gl.CullFace(gl.BACK)

	create_vertex_buffer()
	create_index_buffer()
	
	program_ok: bool;
	program, program_ok = gl.load_shaders_source(vertex_shader, fragment_shader);
	if !program_ok {
		message, compile_type := gl.get_last_error_message()
		fmt.println("failed to load and compile shaders")
		fmt.println(message)
		os.exit(1)
	}
	gl.UseProgram(program)
	gWVPLocation = gl.GetUniformLocation(program, "gWVP")
	if gWVPLocation == -1 {
		fmt.print("Error getting uniform location of gWVP")
		os.exit(1)
	}
	time.stopwatch_start(&watch)
	camera.constructCamera(&gameCamera)
	for !glfw.WindowShouldClose(window_handle) {
		// Process all incoming events like keyboard press, window resize, and etc.
		glfw.PollEvents()
		render_scene()
		glfw.SwapBuffers(window_handle)
	}
}

render_scene :: proc() {
	gl.ClearColor(RED, GREEN, BLUE, ALPHA)
	gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

	raw_duration        := time.stopwatch_duration(watch)
	secs                := f32(time.duration_seconds(raw_duration))
	theta               := f32(secs)

	SCALE += 0.02
	YRoationAngle:f32 = 1.0
	setPosition(0.0, 0.0, 2.0)
	rotate(0.0, YRoationAngle, 0.0)
	world:= getMatrix()
	view:= camera.getMatrix(gameCamera)
	projection:= math3d.initPersProjTransform(projectionInfo)

	final:= projection * view * world
	// FF : f32 = 45
	// thfov := math.tan_f32(math.to_radians_f32(FF/2.0))
	// f := 1/thfov
	// ar :f32= cast(f32) WIDTH / cast(f32) HEIGHT
	// near: f32 = 1
	// far: f32 = 100
	// zrange: f32 = near - far
	// A: f32 = (-far - near) / zrange
	// B: f32 = 2.0 * far * near / zrange
	
	// rotation:=linalg.Matrix4f32{
	// 	math.cos_f32(theta), 0.0, -math.sin_f32(theta), 0.0, 
	// 	0.0, 1.0, 0.0, 0.0, 
	// 	math.sin_f32(theta), 0.0, math.cos_f32(theta), 0.0,
	// 	0.0, 0.0, 0.0, 1.0,
	// }
	// translation:=linalg.Matrix4f32{
	// 	1.0, 0.0, 0.0, 0.0, 
	// 	0.0, 1.0, 0.0, 0.0,
	// 	0.0, 0.0, 1.0, 2.0,
	// 	0.0, 0.0, 0.0, 1.0,
	// }
	// projection:=linalg.Matrix4f32{
	// 	f/ar, 0.0, 0.0, 0.0,
	// 	0.0, f, 0.0, 0.0,
	// 	0.0, 0.0, A, B,
	// 	0.0, 0.0, 1.0, 0.0,
	// }
	//final:=projection * translation * rotation
	//final:=projection * world
	
	gl.UniformMatrix4fv(gWVPLocation, 1, gl.FALSE, &final[0][0])

	gl.BindBuffer(gl.ARRAY_BUFFER, VBO)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, IBO)

	// position
	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 6 * size_of(f32), 0)

	// color
	gl.EnableVertexAttribArray(1)
	gl.VertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, 6 * size_of(f32), 3 * size_of(f32))

	gl.DrawElements(gl.TRIANGLES, 36, gl.UNSIGNED_INT, nil)
	gl.DisableVertexAttribArray(0)
	gl.DisableVertexAttribArray(1)
}

create_vertex_buffer :: proc() {
	v1:= Vertex{}
	vertex(0.5, 0.5, 0.5, &v1)
	v2:= Vertex{}
	vertex(-0.5, 0.5, -0.5, &v2)
	v3:= Vertex{}
	vertex(-0.5, 0.5, 0.5, &v3)
	v4:= Vertex{}
	vertex(0.5, -0.5, -0.5, &v4)
	v5:= Vertex{}
	vertex(-0.5,-0.5, -0.5, &v5)
	v6:= Vertex{}
	vertex(0.5, 0.5, -0.5, &v6)
	v7:= Vertex{}
	vertex(0.5, -0.5, 0.5, &v7)
	v8:= Vertex{}
	vertex(-0.5, -0.5, 0.5, &v8)

	vertices := [8]Vertex{v1, v2, v3, v4, v5, v6, v7, v8}

	gl.GenBuffers(1, &VBO)
	gl.BindBuffer(gl.ARRAY_BUFFER, VBO)
	gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices), &vertices, gl.STATIC_DRAW)
}

create_index_buffer :: proc() {
	indices: [12 * 3]u32 = {
		0, 1, 2,
                1, 3, 4,
                5, 6, 3,
                7, 3, 6,
                2, 4, 7,
                0, 7, 6,
                0, 5, 1,
                1, 5, 3,
                5, 0, 6,
                7, 4, 3,
                2, 1, 4,
                0, 2, 7,
	}

	gl.GenBuffers(1, &IBO)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, IBO)
	gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, size_of(indices), &indices, gl.STATIC_DRAW)
}

keyboardCB:: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32) {
	context = runtime.default_context()
	camera.onKeyboard(key, &gameCamera)
	if key == glfw.KEY_ESCAPE && action == glfw.PRESS {
		glfw.SetWindowShouldClose(window, glfw.TRUE)
	}
}

mouseCB:: proc "c" (window: glfw.WindowHandle, xpos: f64, ypos: f64) {
	context = runtime.default_context()
	camera.onMouse(cast(i32)xpos, cast(i32)ypos, &gameCamera)
}

// A function which simply converts colors specified in hex
// to a triple of floats ranging from 0 to 1.
rgbHexToFractions :: proc( hex_color : int ) -> ( ret : [3] f32 ) {
	ret.r = f32( (hex_color & 0x00_FF_00_00) >> 16 )
	ret.g = f32( (hex_color & 0x00_00_FF_00) >> 8  )
	ret.b = f32( (hex_color & 0x00_00_00_FF) >> 0  )
	ret *= 1.0/255
	return 
    }
