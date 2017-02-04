//
//  Matrix.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 23/01/2017.
//  Copyright © 2017 Simon Rodriguez. All rights reserved.
//

import Foundation

#if os(macOS)
import simd
#endif

#if os(macOS)
public typealias Matrix4 = float4x4
#else
public typealias Matrix4 = internal_float4x4
#endif




public extension Matrix4 {
	
	
	static func translationMatrix(_ t: Point3) -> Matrix4 {
		
		var matrix = Matrix4(1.0)
		matrix[3,0] = t.x
		matrix[3,1] = t.y
		matrix[3,2] = t.z
		return matrix
		
	}
	
	
	static func scaleMatrix(_ x: Scalar) -> Matrix4 {
		
		return Matrix4.scaleMatrix(Point3(x))
	
	}
	
	
	static func scaleMatrix(_ s: Point3) -> Matrix4 {
	
		return Matrix4(diagonal: Point4(s, 1.0))
	
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
		let matrix = Matrix4(rows: [Point4(u,-dot(u, eye)),Point4(v,-dot(v, eye)), Point4(-n,dot(n, eye)), Point4(0.0,0.0,0.0,1.0)])
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
	
	
	static func orthographicMatrix(right: Scalar, top: Scalar, near: Scalar, far: Scalar) -> Matrix4 {
		
		var matrix = Matrix4(1.0)
		matrix[0,0] = 1.0 / right
		matrix[1,1] = 1.0 / top
		matrix[2,2] = 2.0 / (near - far)
		matrix[3,2] = (2.0 * far * near) / (near - far)
		return matrix
		
	}
}


/// MARK: Internal fallback

#if os(macOS)
	// Rely on simd
#else
	
public struct internal_float4x4 {
	
	fileprivate var values = [Scalar](repeating: 0.0, count: 16)
	
	public var transpose: internal_float4x4 {
		get {
			let newValues = [values[0], values[4], values[8], values[12],
							 values[1], values[5], values[9], values[13],
							 values[2], values[6], values[10], values[14],
							 values[3], values[7], values[11], values[15]]
			return internal_float4x4(values: newValues)
		}
	}
	
	public var inverse : internal_float4x4 {
		get {
			var inv = [Scalar](repeating: 0.0, count: 16)
			let m = values
			
			inv[0] = m[5]  * m[10] * m[15] -
				m[5]  * m[11] * m[14] -
				m[9]  * m[6]  * m[15] +
				m[9]  * m[7]  * m[14] +
				m[13] * m[6]  * m[11] -
				m[13] * m[7]  * m[10]
			
			inv[4] = -m[4]  * m[10] * m[15] +
				m[4]  * m[11] * m[14] +
				m[8]  * m[6]  * m[15] -
				m[8]  * m[7]  * m[14] -
				m[12] * m[6]  * m[11] +
				m[12] * m[7]  * m[10]
			
			inv[8] = m[4]  * m[9] * m[15] -
				m[4]  * m[11] * m[13] -
				m[8]  * m[5] * m[15] +
				m[8]  * m[7] * m[13] +
				m[12] * m[5] * m[11] -
				m[12] * m[7] * m[9]
			
			inv[12] = -m[4]  * m[9] * m[14] +
				m[4]  * m[10] * m[13] +
				m[8]  * m[5] * m[14] -
				m[8]  * m[6] * m[13] -
				m[12] * m[5] * m[10] +
				m[12] * m[6] * m[9]
			
			inv[1] = -m[1]  * m[10] * m[15] +
				m[1]  * m[11] * m[14] +
				m[9]  * m[2] * m[15] -
				m[9]  * m[3] * m[14] -
				m[13] * m[2] * m[11] +
				m[13] * m[3] * m[10]
			
			inv[5] = m[0]  * m[10] * m[15] -
				m[0]  * m[11] * m[14] -
				m[8]  * m[2] * m[15] +
				m[8]  * m[3] * m[14] +
				m[12] * m[2] * m[11] -
				m[12] * m[3] * m[10]
			
			inv[9] = -m[0]  * m[9] * m[15] +
				m[0]  * m[11] * m[13] +
				m[8]  * m[1] * m[15] -
				m[8]  * m[3] * m[13] -
				m[12] * m[1] * m[11] +
				m[12] * m[3] * m[9]
			
			inv[13] = m[0]  * m[9] * m[14] -
				m[0]  * m[10] * m[13] -
				m[8]  * m[1] * m[14] +
				m[8]  * m[2] * m[13] +
				m[12] * m[1] * m[10] -
				m[12] * m[2] * m[9]
			
			inv[2] = m[1]  * m[6] * m[15] -
				m[1]  * m[7] * m[14] -
				m[5]  * m[2] * m[15] +
				m[5]  * m[3] * m[14] +
				m[13] * m[2] * m[7] -
				m[13] * m[3] * m[6]
			
			inv[6] = -m[0]  * m[6] * m[15] +
				m[0]  * m[7] * m[14] +
				m[4]  * m[2] * m[15] -
				m[4]  * m[3] * m[14] -
				m[12] * m[2] * m[7] +
				m[12] * m[3] * m[6]
			
			inv[10] = m[0]  * m[5] * m[15] -
				m[0]  * m[7] * m[13] -
				m[4]  * m[1] * m[15] +
				m[4]  * m[3] * m[13] +
				m[12] * m[1] * m[7] -
				m[12] * m[3] * m[5]
			
			inv[14] = -m[0]  * m[5] * m[14] +
				m[0]  * m[6] * m[13] +
				m[4]  * m[1] * m[14] -
				m[4]  * m[2] * m[13] -
				m[12] * m[1] * m[6] +
				m[12] * m[2] * m[5]
			
			inv[3] = -m[1] * m[6] * m[11] +
				m[1] * m[7] * m[10] +
				m[5] * m[2] * m[11] -
				m[5] * m[3] * m[10] -
				m[9] * m[2] * m[7] +
				m[9] * m[3] * m[6]
			
			inv[7] = m[0] * m[6] * m[11] -
				m[0] * m[7] * m[10] -
				m[4] * m[2] * m[11] +
				m[4] * m[3] * m[10] +
				m[8] * m[2] * m[7] -
				m[8] * m[3] * m[6]
			
			inv[11] = -m[0] * m[5] * m[11] +
				m[0] * m[7] * m[9] +
				m[4] * m[1] * m[11] -
				m[4] * m[3] * m[9] -
				m[8] * m[1] * m[7] +
				m[8] * m[3] * m[5]
			
			inv[15] = m[0] * m[5] * m[10] -
				m[0] * m[6] * m[9] -
				m[4] * m[1] * m[10] +
				m[4] * m[2] * m[9] +
				m[8] * m[1] * m[6] -
				m[8] * m[2] * m[5]
			
			var det = m[0] * inv[0] + m[1] * inv[4] + m[2] * inv[8] + m[3] * inv[12];
			
			if det == 0.0 {
				fatalError("Non invertible matrix")
			}
			
			det = 1.0 / det
			
			for i in 0..<16 {
				inv[i] *= det
			}
			
			return Matrix4(values: inv)
		}
	}
	
	public init() { }
	
	
	public init(_ val: Scalar) {
		
		self.init()
		values[0] = val
		values[5] = val
		values[10] = val
		values[15] = val
		
	}
	
	
	public init(diagonal: Point4) {
		
		self.init()
		values[0] = diagonal.x
		values[5] = diagonal.y
		values[10] = diagonal.z
		values[15] = diagonal.w
		
	}
	
	
	public init(rows: [Point4]) {
		
		self.init()
		values[0] = rows[0].x
		values[1] = rows[0].y
		values[2] = rows[0].z
		values[3] = rows[0].w
		values[4] = rows[1].x
		values[5] = rows[1].y
		values[6] = rows[1].z
		values[7] = rows[1].w
		values[8] = rows[2].x
		values[9] = rows[2].y
		values[10] = rows[2].z
		values[11] = rows[2].w
		values[12] = rows[3].x
		values[13] = rows[3].y
		values[14] = rows[3].z
		values[15] = rows[3].w
		
	}
	
	fileprivate init(values _values: [Scalar]) {
		
		values = _values
		
	}
	
	
	public subscript(col: Int, row: Int) -> Scalar {
		
		get {
			return values[row*4+col]
		}
		
		set(val) {
			values[row*4+col] = val
		}
		
	}
	
	
}

public func * (left: internal_float4x4, right: internal_float4x4) -> internal_float4x4 {
	let m1 = left.values
	let m2 = right.values
	var m = [Scalar](repeating: 0.0, count: 16)
	m[ 0] = m1[ 0]*m2[ 0] + m1[ 1]*m2[ 4] + m1[ 2]*m2[ 8] + m1[ 3]*m2[12]
	m[ 1] = m1[ 0]*m2[ 1] + m1[ 1]*m2[ 5] + m1[ 2]*m2[ 9] + m1[ 3]*m2[13]
	m[ 2] = m1[ 0]*m2[ 2] + m1[ 1]*m2[ 6] + m1[ 2]*m2[10] + m1[ 3]*m2[14]
	m[ 3] = m1[ 0]*m2[ 3] + m1[ 1]*m2[ 7] + m1[ 2]*m2[11] + m1[ 3]*m2[15]
	m[ 4] = m1[ 4]*m2[ 0] + m1[ 5]*m2[ 4] + m1[ 6]*m2[ 8] + m1[ 7]*m2[12]
	m[ 5] = m1[ 4]*m2[ 1] + m1[ 5]*m2[ 5] + m1[ 6]*m2[ 9] + m1[ 7]*m2[13]
	m[ 6] = m1[ 4]*m2[ 2] + m1[ 5]*m2[ 6] + m1[ 6]*m2[10] + m1[ 7]*m2[14]
	m[ 7] = m1[ 4]*m2[ 3] + m1[ 5]*m2[ 7] + m1[ 6]*m2[11] + m1[ 7]*m2[15]
	m[ 8] = m1[ 8]*m2[ 0] + m1[ 9]*m2[ 4] + m1[10]*m2[ 8] + m1[11]*m2[12]
	m[ 9] = m1[ 8]*m2[ 1] + m1[ 9]*m2[ 5] + m1[10]*m2[ 9] + m1[11]*m2[13]
	m[10] = m1[ 8]*m2[ 2] + m1[ 9]*m2[ 6] + m1[10]*m2[10] + m1[11]*m2[14]
	m[11] = m1[ 8]*m2[ 3] + m1[ 9]*m2[ 7] + m1[10]*m2[11] + m1[11]*m2[15]
	m[12] = m1[12]*m2[ 0] + m1[13]*m2[ 4] + m1[14]*m2[ 8] + m1[15]*m2[12]
	m[13] = m1[12]*m2[ 1] + m1[13]*m2[ 5] + m1[14]*m2[ 9] + m1[15]*m2[13]
	m[14] = m1[12]*m2[ 2] + m1[13]*m2[ 6] + m1[14]*m2[10] + m1[15]*m2[14]
	m[15] = m1[12]*m2[ 3] + m1[13]*m2[ 7] + m1[14]*m2[11] + m1[15]*m2[15]
	return internal_float4x4(values: m)
}

public func * (left: internal_float4x4, rhs: Point4) -> Point4 {
	let m1 = left.values
	var m : Point4 = Point4(0.0)
	m.x = m1[ 0]*rhs.x + m1[ 1]*rhs.y + m1[ 2]*rhs.z + m1[ 3]*rhs.w
	m.y = m1[ 4]*rhs.x + m1[ 5]*rhs.y + m1[ 6]*rhs.z + m1[ 7]*rhs.w
	m.z = m1[ 8]*rhs.x + m1[ 9]*rhs.y + m1[10]*rhs.z + m1[11]*rhs.w
	m.w = m1[12]*rhs.x + m1[13]*rhs.y + m1[14]*rhs.z + m1[15]*rhs.w
	return m
}

#endif
