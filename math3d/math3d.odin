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
	return linalg.Matrix4f32{
		ScaleX, 0.0, 0.0, 0.0,
		0.0, ScaleY, 0.0, 0.0,
		0.0, 0.0, ScaleZ, 0.0,
		0.0, 0.0, 0.0, 1.0,
	}
}

initRotateTransform::proc(RotateX: f32, RotateY: f32, RotateZ: f32) -> linalg.Matrix4f32 {
	x:f32 = math.to_radians_f32(RotateX)
	y:f32 = math.to_radians_f32(RotateY)
	z:f32 = math.to_radians_f32(RotateZ)

	rx:= initRotationX(x)
	ry:= initRotationY(y)
	rz:= initRotationZ(z)

	return rx * ry * rz
	//return ry;
	// return linalg.Matrix4f32{
	// 	math.cos_f32(y), 0.0, -math.sin_f32(y), 0.0, 
	// 	0.0, 1.0, 0.0, 0.0, 
	// 	math.sin_f32(y), 0.0, math.cos_f32(y), 0.0,
	// 	0.0, 0.0, 0.0, 1.0,
	// }
}

initTranslateTransform::proc(x: f32, y: f32, z: f32) -> linalg.Matrix4f32 {
	return linalg.Matrix4f32{
		1.0, 0.0, 0.0, x,
		0.0, 1.0, 0.0, y,
		0.0, 0.0, 1.0, z,
		0.0, 0.0, 0.0, 1.0,
	}
}

initRotationX::proc(angleInRadians: f32) -> linalg.Matrix4f32 {
	return linalg.Matrix4f32{
		1.0, 0.0, 0.0, 0.0,
		0.0, math.cos_f32(angleInRadians), math.sin_f32(angleInRadians), 0.0,
		0.0, -math.sin_f32(angleInRadians), math.cos_f32(angleInRadians), 0.0,
		0.0, 0.0, 0.0, 1.0,
	}
}

initRotationY::proc(angleInRadians: f32) -> linalg.Matrix4f32 {
	return linalg.Matrix4f32{
		math.cos_f32(angleInRadians), 0.0, -math.sin_f32(angleInRadians), 0.0,
		0.0, 1.0, 0.0, 0.0,
		math.sin_f32(angleInRadians), 0.0, math.cos_f32(angleInRadians), 0.0,
		0.0, 0.0, 0.0, 1.0,
	}
}

initRotationZ::proc(angleInRadians: f32) -> linalg.Matrix4f32 {
	return linalg.Matrix4f32{
		math.cos_f32(angleInRadians), math.sin_f32(angleInRadians), 0.0, 0.0,
		-math.sin_f32(angleInRadians), math.cos_f32(angleInRadians), 0.0, 0.0,
		0.0, 0.0, 1.0, 0.0,
		0.0, 0.0, 0.0, 1.0,
	}
}

initPersProjTransform::proc(projectionInfo: PersProjInfo) -> linalg.Matrix4f32 {
	ar: f32 = cast(f32) projectionInfo.Height / cast(f32) projectionInfo.Width
	zrange: f32 = projectionInfo.zNear - projectionInfo.zFar
	tanHalfFOV: f32 = math.tan_f32(math.to_radians_f32(projectionInfo.FOV / 2.0))
	return linalg.Matrix4f32{
		1/tanHalfFOV, 0.0, 0.0, 0.0,
		0.0, 1.0/(tanHalfFOV*ar), 0.0, 0.0,
		0.0, 0.0, (-projectionInfo.zNear - projectionInfo.zFar)/zrange, 2.0*projectionInfo.zFar*projectionInfo.zNear/zrange,
		0.0, 0.0, 1.0, 0.0,
	}

	//final:= projection * view * world
	// FF : f32 = 45
	// thfov := math.tan_f32(math.to_radians_f32(FF/2.0))
	// f := 1/thfov
	// ar :f32= cast(f32) WIDTH / cast(f32) HEIGHT
	// near: f32 = 1
	// far: f32 = 100
	// zrange: f32 = near - far
	// A: f32 = (-far - near) / zrange
	// B: f32 = 2.0 * far * near / zrange

	// projection:=linalg.Matrix4f32{
	// 	f/ar, 0.0, 0.0, 0.0,
	// 	0.0, f, 0.0, 0.0,
	// 	0.0, 0.0, A, B,
	// 	0.0, 0.0, 1.0, 0.0,
	// }
}