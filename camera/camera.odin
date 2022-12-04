package camera

import "core:math"
import "core:fmt"
import "core:math/linalg"
import "core:c/libc"
import "vendor:glfw"

MARGIN:i32 = 10
EDGE_STEP:f32 = 1.0

Camera :: struct  {
	speed: f32,
	windowWidth: i32,
	windowHeight: i32,
	pos: linalg.Vector3f32,
	target: linalg.Vector3f32,
	up: linalg.Vector3f32,
	angleH: f32,
	angleV: f32,
	onUpperEdge: bool,
	onLowerEdge: bool,
	onLeftEdge: bool,
	onRightEdge: bool,
	mousePos: linalg.Vector2f32,
}

setCameraPosition::proc(x: f32, y: f32, z: f32, camera: ^Camera) {
	camera.pos.x = x
	camera.pos.y = y
	camera.pos.z = z
}

constructCamera::proc(using self: ^Camera) {
	self.target = linalg.vector_normalize(self.target)
	self.up = linalg.vector_normalize(self.up)

	init(self)
}

init::proc(using self: ^Camera) {
	htarget:= linalg.Vector3f32{self.target.x, 0.0, self.target.y}
	angle := math.to_degrees_f32(math.asin(math.abs(htarget.z)))

	if htarget.z >= 0.0 {
		if htarget.x >= 0.0 {
			self.angleH = 360.0 - angle
		} else {
			self.angleH = 180.0 + angle
		}
	} else {
		if htarget.x > 0.0 {
			self.angleH = angle
		} else {
			self.angleH = 180.0 - angle
		}
	}

	self.angleV = -math.to_degrees(math.asin(self.target.y))
	self.onUpperEdge = false
	self.onLeftEdge = false
	self.onLeftEdge = false
	self.onRightEdge = false
	self.mousePos.x = cast(f32) windowWidth / 2
	self.mousePos.y = cast(f32) windowHeight / 2

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

onMouse::proc (x: i32, y: i32, using self: ^Camera) {
	deltax: i32 = cast(i32) (x - cast(i32) self.mousePos.x)
	deltay: i32 = cast(i32) (y - cast(i32) self.mousePos.y)
	self.mousePos.x = cast(f32) x;
	self.mousePos.y = cast(f32) y;

	self.angleH += cast(f32) deltax / 20.0
	self.angleV += cast(f32) deltay / 50.0

	if deltax == 0 {
		if x <= MARGIN {
			self.onLeftEdge = true
		}
		else if x >= (self.windowWidth - MARGIN) {
			self.onRightEdge = true
		}
	} else {
		self.onLeftEdge = true
		self.onRightEdge = true
	}

	if deltay == 0 {
		if y <= MARGIN {
			self.onUpperEdge = true
		} else if y >= (self.windowHeight - MARGIN) {
			self.onLowerEdge = true
		}
	} else {
		self.onUpperEdge = true
		self.onLowerEdge = true
	}

	update(self)
}

update::proc(using self: ^Camera) {
	yaxis:= linalg.Vector3f32{0.0, 1.0, 0.0}
	view:= linalg.Vector3f32{1.0, 0.0, 0.0}
	
	rotationQ1:= linalg.quaternion_angle_axis_f32(self.angleH, yaxis)
	v1: = linalg.mul(rotationQ1, view)
	v1n: = linalg.vector_normalize(v1)

	u:= linalg.cross(yaxis, v1n)
	un: = linalg.vector_normalize(u)
	rotationQ2:= linalg.quaternion_angle_axis_f32(self.angleV, un)
	v2: = linalg.mul(rotationQ2, v1n)
	self.target = linalg.vector_normalize(v2)
	self.up = linalg.vector_normalize(linalg.vector_cross3(self.target, un))
}

onRender::proc(using self: ^Camera) {
	shouldUpdate:= false
	if self.onLeftEdge {
		self.angleH -= EDGE_STEP
		shouldUpdate = true
	} else if self.onRightEdge {
		angleH += EDGE_STEP
		shouldUpdate = true
	}

	if self.onUpperEdge {
		if self.angleV > -90.0 {
			self.angleV -= EDGE_STEP
			shouldUpdate = true
		}
	} else if self.onLowerEdge {
		if self.angleV < 90.0 {
			self.angleV += EDGE_STEP
			shouldUpdate = true
		}
	}

	if shouldUpdate {
		update(self)
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