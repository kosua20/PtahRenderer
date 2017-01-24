//
//  Matrix.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 23/01/2017.
//  Copyright © 2017 Simon Rodriguez. All rights reserved.
//

import Foundation
import simd

typealias Matrix4 = float4x4


internal extension Matrix4 {
	
	
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
		
		let matrix = Matrix4(rows: [float4(u.x * u.x * mc + c, xy - zs, xz + ys, 0.0),
		                            float4(xy + zs, u.y * u.y * mc + c, yz - xs, 0.0),
		                            float4(xz - ys, yz + xs, u.z * u.z * mc + c, 0.0),
		                            float4(0.0,0.0,0.0,1.0)])
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
