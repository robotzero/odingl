package main

import "core:math"
import "core:math/linalg"
import "math3d"

scale: f32 = 1.0
rotation:= linalg.Vector3f32{0.0, 0.0, 0.0}
position:= linalg.Vector3f32{0.0, 0.0, 0.0}

setScale::proc(s: f32) {
	scale = s;
}

setRotation::proc(x: f32, y: f32, z: f32) {
	rotation.x = x
	rotation.y = y
	rotation.z = z
}

setPosition::proc(x: f32, y: f32, z: f32) {
	position.x = x
	position.y = y
	position.z = z
}

rotate::proc(x: f32, y: f32, z: f32) {
	rotation.x += x
	rotation.y += y
	rotation.z += z
}

getMatrix::proc() -> linalg.Matrix4f32 {
	scaleMatrix:= math3d.initScaleTransform(scale, scale, scale)
	rotationMatrix:= math3d.initRotateTransform(rotation.x, rotation.y, rotation.z)
	translationMatrix: = math3d.initTranslateTransform(position.x, position.y, position.z)
	
	return translationMatrix * rotationMatrix * scaleMatrix
}
