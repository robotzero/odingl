package math3d

import "core:math"
import "core:math/linalg"

PersProjInfo :: struct {
     FOV: f32,
     Width: f32,
     Height: f32,
     zNear: f32,
     zFar: f32,
}

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

initPersProjTransform::proc(projectionInfo: PersProjInfo) -> linalg.Matrix4f32 {
	ar: f32 = projectionInfo.Height / projectionInfo.Width
	zrange: f32 = projectionInfo.zNear - projectionInfo.zFar
	tanHalfFOV: f32 = math.tan_f32(toRadian(projectionInfo.FOV / 2.0))
	return linalg.Matrix4f32{1/tanHalfFOV, 0.0, 0.0, 0.0, 0.0, 1.0/(tanHalfFOV*ar), 0.0, 0.0, 0.0, 0.0, (-projectionInfo.zNear - projectionInfo.zFar)/zrange, 1.0, 0.0, 0.0, 2.0*projectionInfo.zNear/zrange, 0.0}
}