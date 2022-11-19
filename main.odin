package main

import "core:fmt"
import "core:math/linalg"
import "core:os"
import "core:c"
import "core:strings"
import "core:runtime"
import "vendor:glfw"
import "core:math"
import gl "vendor:OpenGL"
import "math3d"
import "camera"

WIDTH  	:: 2560
HEIGHT 	:: 1440
TITLE 	:: "Tutorial 08"
RED 	:: 0.0
GREEN	:: 0.0
BLUE	:: 0.0
ALPHA	:: 0.0
SCALE: f32 = 1.0
DELTA: f32 = 0.01
ANGLE_IN_RADIANS: f32 = 0.0
LOC: f32 = 0.0

// @note You might need to lower this to 3.3 depending on how old your graphics card is.
GL_MAJOR_VERSION :: 4
GL_MINOR_VERSION :: 6
VBO: u32
gTranslationLocation: i32
gRotationLocation: i32
gScalingLocation: i32
gameCamera: camera.Camera = camera.Camera{1.0, linalg.Vector3f32{0.0, 0.0, 0.0}, linalg.Vector3f32{0.0, 0.0, 0.0}, linalg.Vector3f32{0.0, 0.0, 0.0}}

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
	glfw.MakeContextCurrent(window_handle)
	glfw.SwapInterval(1)
	// Load OpenGL function pointers with the specficed OpenGL major and minor version.
	gl.load_up_to(GL_MAJOR_VERSION, GL_MINOR_VERSION, glfw.gl_set_proc_address)
	//gl.Enable(gl.DEPTH_TEST)
	
	create_vertex_buffer()
	compile_gpu_program()
	
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

	// ANGLE_IN_RADIANS += DELTA;
	// if ANGLE_IN_RADIANS >= 1.5708 || ANGLE_IN_RADIANS <= -1.5708 {
	// 	DELTA *= -1.0
	// }

	SCALE = 0.5

	LOC += DELTA
	if LOC >= 0.5 || LOC <= -0.5 {
		DELTA *= -1.0
	}

	Translation := math3d.initTranslateTransform(LOC, 0.0, 0.0)
	Rotation:= linalg.Matrix4f32{math.cos_f32(ANGLE_IN_RADIANS), -math.sin_f32(ANGLE_IN_RADIANS), 0.0, 0.0, math.sin_f32(ANGLE_IN_RADIANS), math.cos_f32(ANGLE_IN_RADIANS), 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0}
	Scaling := math3d.initScaleTransform(SCALE, SCALE, SCALE)
	FinalTransform := Scaling * Translation;

	// gl.UniformMatrix4fv(gTranslationLocation, 1, gl.FALSE, &Translation[0][0])
	// gl.UniformMatrix4fv(gRotationLocation, 1, gl.FALSE, &Rotation[0][0])
	gl.UniformMatrix4fv(gScalingLocation, 1, gl.FALSE, &FinalTransform[0][0])

	gl.BindBuffer(gl.ARRAY_BUFFER, VBO)
	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 0, 0)
	gl.DrawArrays(gl.TRIANGLES, 0, 3)
	gl.DisableVertexAttribArray(0)
}

create_vertex_buffer :: proc() {
	vertices := [3]linalg.Vector3f32{
		linalg.Vector3f32{-1.0, -1.0, 0.0}, // bottom left
		linalg.Vector3f32{1.0, -1.0, 0.0},  // bottom right
		linalg.Vector3f32{0.0, 1.0, 0.0},   // top
	}

	gl.GenBuffers(1, &VBO)
	gl.BindBuffer(gl.ARRAY_BUFFER, VBO)
	gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices), &vertices, gl.STATIC_DRAW)
}

compile_gpu_program :: proc() {
	shader_program: u32 = gl.CreateProgram()
	if (shader_program == 0) {
		fmt.println("Error creating shader program")
		os.exit(0)
	}
	vertex_shader, okv := os.read_entire_file_from_filename("vertex.glsl")
	if !okv {
		fmt.println("Error creating shader program")
		os.exit(1)
	}
	
	add_gpu_program(shader_program, string(vertex_shader), gl.VERTEX_SHADER)
	defer delete(vertex_shader, context.allocator)
	fragment_shader, okf := os.read_entire_file_from_filename("fragment.glsl")

	if !okf {
		fmt.println("Error creating shader program")
		os.exit(1)
	}
	add_gpu_program(shader_program, string(fragment_shader), gl.FRAGMENT_SHADER)
	defer delete(fragment_shader, context.allocator)

	ok: i32
	erroLog: [^]u8 = {}
	gl.LinkProgram(shader_program)
	gl.GetProgramiv(shader_program, gl.LINK_STATUS, &ok)
	if ok != 1 {
		gl.GetProgramInfoLog(shader_program, 1024, nil, erroLog)
		fmt.print("Unable to link shader program: {}", erroLog)
		os.exit(1)
	}

	// gTranslationLocation = gl.GetUniformLocation(shader_program, "gTranslation")
	// if gTranslationLocation == -1 {
	// 	fmt.print("Error getting uniform location of gtranslation")
	// 	os.exit(1)
	// }

	// gRotationLocation = gl.GetUniformLocation(shader_program, "gRotation")
	// if gRotationLocation == -1 {
	// 	fmt.print("Error getting uniform location of gRotation")
	// 	os.exit(1)
	// }

	gScalingLocation = gl.GetUniformLocation(shader_program, "gScaling")
	if gScalingLocation == -1 {
		fmt.print("Error getting uniform location of gScaling")
		os.exit(1)
	}

	gl.ValidateProgram(shader_program)
	gl.GetProgramiv(shader_program, gl.VALIDATE_STATUS, &ok)
	if ok != 1 {
		gl.GetProgramInfoLog(shader_program, 1024, nil, erroLog)
		fmt.print("Unable to validate shader program: {}", erroLog)
		os.exit(1)
	}

	gl.UseProgram(shader_program)

	defer gl.DeleteProgram(shader_program)
}

add_gpu_program :: proc(shader_program: u32, shader_text: string, shader_type: u32) {
	shader_object: u32 = gl.CreateShader(shader_type)
	if (shader_object == 0) {
		fmt.println("Error creating shader")
		os.exit(0)
	}
	data := strings.clone_to_cstring(shader_text, context.temp_allocator)
	data_length : i32 = cast(i32)len(shader_text)
	gl.ShaderSource(shader_object, 1, &data, &data_length)
	gl.CompileShader(shader_object)
	ok: i32
	gl.GetShaderiv(shader_object, gl.COMPILE_STATUS, &ok)
	if ok != 1 {
		infoLog: [^]u8
		gl.GetShaderInfoLog(shader_object, 1024, nil, infoLog)
		fmt.println("Unable to compile shader: {}", shader_object)
		os.exit(0)
	}
	gl.AttachShader(shader_program, shader_object)
}

keyboardCB:: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32) {
	context = runtime.default_context()
	camera.onKeyboard(key, &gameCamera)
}
