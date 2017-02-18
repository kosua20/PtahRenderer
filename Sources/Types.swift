
import Foundation
import simd


typealias Scalar = Float
typealias Point3 = float3
typealias Point4 = float4
typealias Point2 = float2
typealias Matrix4 = float4x4


func ==(lhs: Point2, rhs: Point2) -> Bool {
	return lhs.x == rhs.x && lhs.y == rhs.y
}

func ==(lhs: Point3, rhs: Point3) -> Bool {
	return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
}

func ==(lhs: Point4, rhs: Point4) -> Bool {
	return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z && lhs.w == rhs.w
}


extension Matrix4 {
	
	static func translationMatrix(_ t: Point3) -> Matrix4 {
		var matrix = Matrix4(1.0)
		matrix[3,0] = t.x
		matrix[3,1] = t.y
		matrix[3,2] = t.z
		return matrix
	}
	
	static func scaleMatrix(_ x: Scalar) -> Matrix4 {
		return Matrix4(diagonal: Point4(x,x,x, 1.0))
	}
	
	static func rotationMatrix(angle: Scalar, axis: Point3) -> Matrix4 {
		let u = normalize(axis)
		let c = cos(angle)
		let mc = 1.0 - c
		let s = sin(angle)
		let xy = u.x * u.y * mc
		let xz = u.x * u.z * mc
		let yz = u.y * u.z * mc
		let xs = u.x * s
		let ys = u.y * s
		let zs = u.z * s
		let matrix = Matrix4(rows: [Point4(u.x * u.x * mc + c, xy - zs, xz + ys, 0.0),
		                            Point4(xy + zs, u.y * u.y * mc + c, yz - xs, 0.0),
		                            Point4(xz - ys, yz + xs, u.z * u.z * mc + c, 0.0),
		                            Point4(0.0,0.0,0.0,1.0)])
		return matrix
	}
	
	static func lookAtMatrix(eye: Point3, target: Point3, up: Point3) -> Matrix4 {
		let n = normalize(target - eye)
		var v = normalize(up)
		let u = normalize(cross(n, v))
		v = normalize(cross(u, n))
		let matrix = Matrix4(rows: [Point4(u.x, u.y, u.z, -dot(u, eye)),
		                            Point4(v.x, v.y, v.z, -dot(v, eye)),
		                            Point4(-n.x, -n.y, -n.z, dot(n, eye)),
		                            Point4(0.0,0.0,0.0,1.0)])
		return matrix
	}
	
	static func perspectiveMatrix(fov: Scalar, aspect: Scalar, near: Scalar, far: Scalar) -> Matrix4 {
		var matrix = Matrix4(0.0)
		let radfov = Scalar(M_PI) * fov / 180.0
		let f = 1.0 / tan(radfov / 2.0)
		matrix[0,0] = f / aspect
		matrix[1,1] = f
		matrix[2,2] = (far + near) / (near - far)
		matrix[3,2] = (2.0 * far * near) / (near - far)
		matrix[2,3] = -1.0
		matrix[3,3] = 0.0
		return matrix
	}
	
}
