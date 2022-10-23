package math3d

import "core:math"
import "core:math/linalg"

initScaleTransform::proc(ScaleX: f32, ScaleY: f32, ScaleZ: f32) -> linalg.Matrix4f32 {
	return linalg.Matrix4f32{ScaleX, 0.0, 0.0, 0.0, 0.0, ScaleY, 0.0, 0.0, 0.0, 0.0, ScaleZ, 0.0, 0.0, 0.0, 0.0, 1.0}
}

initRotateTransform::proc(RotateX: f32, RotateY: f32, RotateZ: f32) -> linalg.Matrix4f32 {
	x:f32 = toRadian(RotateX)
	y:f32 = toRadian(RotateY)
	z:f32 = toRadian(RotateZ)

	rx:= initRotation(x)
	ry:= initRotation(y)
	rz:= initRotation(z)

	return rx * ry * rz
}

initTranslateTransform::proc(x: f32, y: f32, z: f32) -> linalg.Matrix4f32 {
	return linalg.Matrix4f32{1.0, 0.0, 0.0, x, 0.0, 1.0, 0.0, y, 0.0, 0.0, 1.0, z, 0.0, 0.0, 0.0, 1.0}
}

initRotation::proc(angleInRadians: f32) -> linalg.Matrix4f32 {
	return linalg.Matrix4f32{math.cos_f32(angleInRadians), -math.sin_f32(angleInRadians), 0.0, 0.0, math.sin_f32(angleInRadians), math.cos_f32(angleInRadians), 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0}
}

toRadian::proc(x: f32) -> f32 {
	return x * math.PI / 180.0
}

toDegrees::proc(x:f32) -> f32 {
	return x * 180.0 / math.PI
}