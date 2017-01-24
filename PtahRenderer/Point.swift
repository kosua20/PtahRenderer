//
//  Point.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 14/02/2016.
//  Copyright © 2016 Simon Rodriguez. All rights reserved.
//

import Foundation

import simd

typealias Scalar = Float
typealias Point4 = float4
typealias Point3 = float3
typealias Point2 = float2
typealias Vertex = Point3
typealias Normal = Point3
typealias UV = Point2



func ==(lhs: Point2, rhs: Point2) -> Bool {
	
	return lhs.x == rhs.x && lhs.y == rhs.y

}


func !=(lhs: Point2, rhs: Point2) -> Bool {

	return lhs.x != rhs.x || lhs.y != rhs.y

}


func ==(lhs: Point3, rhs: Point3) -> Bool {

	return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z

}


func !=(lhs: Point3, rhs: Point3) -> Bool {
	
	return lhs.x != rhs.x || lhs.y != rhs.y || lhs.z != rhs.z

}


func ==(lhs: Point4, rhs: Point4) -> Bool {

	return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z && lhs.w == rhs.w

}


func !=(lhs: Point4, rhs: Point4) -> Bool {

	return lhs.x != rhs.x || lhs.y != rhs.y || lhs.z != rhs.z || lhs.w != rhs.w

}


func clamp(_ x: Scalar, _ a: Scalar, _ b: Scalar) -> Scalar {
	
	return min(b, max(a, x))
	
}


func clamp(_ x: UInt8, _ a: UInt8, _ b: UInt8) -> UInt8 {
	
	return min(b, max(a, x))
	
}


func clamp(_ x: Int, _ a: Int, _ b: Int) -> Int {
	
	return min(b, max(a, x))
	
}



internal extension Point3 {
	
	internal init(_ v: Point4) {
		
		self.init(v.x, v.y, v.z)
		
	}
}


internal extension Point4 {
	
	internal init(_ v: Point3, _ wval: Float) {
		
		self.init()
		x = v.x
		y = v.y
		z = v.z
		w = wval
		
	}
	
}
