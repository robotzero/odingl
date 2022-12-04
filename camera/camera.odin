package camera

import "core:math"
import "core:fmt"
import "core:math/linalg"
import "vendor:glfw"

Camera :: struct  {
	speed: f32,
	pos: linalg.Vector3f32,
	target: linalg.Vector3f32,
	up: linalg.Vector3f32,
}

setCameraPosition::proc(x: f32, y: f32, z: f32, camera: ^Camera) {
	camera.pos.x = x
	camera.pos.y = y
	camera.pos.z = z
}

onKeyboard::proc (key: i32, camera: ^Camera) {
	switch key {
		case glfw.KEY_UP: camera.pos += camera.target * camera.speed
		case glfw.KEY_DOWN: camera.pos -= camera.target * camera.speed
		case glfw.KEY_LEFT: {
			left: linalg.Vector3f32 = linalg.vector_normalize(linalg.vector_cross3(camera.target, camera.up))
			left *= camera.speed
			camera.pos += left
		}
		case glfw.KEY_RIGHT: {
			right: linalg.Vector3f32 = linalg.vector_normalize(linalg.vector_cross3(camera.up, camera.target))
			right *= camera.speed
			camera.pos += right
		}
		case glfw.KEY_PAGE_UP: camera.pos.y += camera.speed
		case glfw.KEY_PAGE_DOWN: camera.pos.y -= camera.speed
		case glfw.KEY_MINUS: {
			camera.speed -= 0.1
			if camera.speed < 0.1 {
				camera.speed = 0.1
			}
			//fmt.println("Camera speed changed")
		}
		case glfw.KEY_RIGHT_BRACKET: {
			camera.speed += 0.1
			//fmt.println("Camera speed changed")
		}

	}
}

getMatrix::proc(gameCamera: Camera) -> linalg.Matrix4x4f32 {
	return initCameraTransform(gameCamera.pos, gameCamera.target, gameCamera.up)
}

initCameraTransform::proc(pos: linalg.Vector3f32, target: linalg.Vector3f32, up: linalg.Vector3f32) -> linalg.Matrix4x4f32 {
	return initCameraTransform2(target, up) * initTranslationTransform(-pos.x, -pos.y, -pos.z)
}

initTranslationTransform::proc(x: f32, y: f32, z: f32) -> linalg.Matrix4x4f32 {
	return linalg.Matrix4f32{
		1.0, 0.0, 0.0, x,
		0.0, 1.0, 0.0, y,
		0.0, 0.0, 1.0, z,
		0.0, 0.0, 0.0, 1.0,
	}
}

initCameraTransform2::proc(target: linalg.Vector3f32, up: linalg.Vector3f32) -> linalg.Matrix4x4f32 {
	n:= linalg.vector_normalize(target)
	upN:= linalg.vector_normalize(up)
	u:= linalg.vector_normalize(linalg.vector_cross3(upN, n))
	v:= linalg.vector_cross3(n, u)
	return linalg.Matrix4x4f32{
		u.x, u.y, u.z, 0.0,
		v.z, v.y, v.z, 0.0,
		n.x, n.y, n.z, 0.0,
		0.0, 0.0, 0.0, 1.0,
	}
}