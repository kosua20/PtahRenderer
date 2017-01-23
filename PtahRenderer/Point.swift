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


func clamp(_ x: float2, _ a: float2, _ b: float2) -> float2 {
	
	return min(b, max(a, x))
	
}


public extension float3 {
	
	public init(_ v: float4) {
		
		self.init(v.x, v.y, v.z)
		
	}
}


public extension float4 {
	
	public init(_ v: float3, _ wval: Float) {
		
		self.init()
		x = v.x
		y = v.y
		z = v.z
		w = wval
		
	}
	
}


func reflect(_ lhs: Point3, _ rhs: Point3) -> Point3 {
	return lhs - 2.0 * dot(rhs, lhs) * rhs
}

/*--Point2--------*/
/*
func +(lhs: Point2, rhs: Point2) -> Point2 {
	return lhs + rhs
}

func +=(lhs: inout Point2, rhs: Point2) {
	lhs.0 += rhs.0
	lhs.1 += rhs.1
}

func -(lhs: Point2, rhs: Point2) -> Point2 {
	return (lhs.0 - rhs.0, lhs.1-rhs.1)
}

func -=(lhs: inout Point2, rhs: Point2) {
	lhs.0 -= rhs.0
	lhs.1 -= rhs.1
}

func *(lhs: Scalar, rhs: Point2) -> Point2 {
	return (lhs*rhs.0, lhs*rhs.1)
}

func *(rhs: Point2, lhs: Scalar) -> Point2 {
	return (lhs*rhs.0, lhs*rhs.1)
}

func *=(lhs: inout Point2, rhs: Scalar){
	lhs.0 = lhs.0*rhs
	lhs.1 = lhs.1*rhs
}

func /(rhs: Point2, lhs: Scalar) -> Point2 {
	return (rhs.0/lhs, rhs.1/lhs)
}

func /=(lhs: inout Point2, rhs: Scalar){
	lhs.0 = lhs.0/rhs
	lhs.1 = lhs.1/rhs
}

*/
/*--Point3--------*/
/*
func +(lhs: Point3, rhs: Point3) -> Point3 {
	return (lhs.0 + rhs.0, lhs.1+rhs.1, lhs.2+rhs.2)
}

func +=(lhs: inout Point3, rhs: Point3) {
	lhs.0 += rhs.0
	lhs.1 += rhs.1
	lhs.2 += rhs.2
}

func -(lhs: Point3, rhs: Point3) -> Point3 {
	return (lhs.0 - rhs.0, lhs.1-rhs.1, lhs.2-rhs.2)
}

func -=(lhs: inout Point3, rhs: Point3) {
	lhs.0 -= rhs.0
	lhs.1 -= rhs.1
	lhs.2 -= rhs.2
}

func *(lhs: Scalar, rhs: Point3) -> Point3 {
	return (lhs*rhs.0, lhs*rhs.1, lhs*rhs.2)
}

func *(rhs: Point3, lhs: Scalar) -> Point3 {
	return (lhs*rhs.0, lhs*rhs.1, lhs*rhs.2)
}

func *=(lhs: inout Point3, rhs: Scalar){
	lhs.0 = lhs.0*rhs
	lhs.1 = lhs.1*rhs
	lhs.2 = lhs.2*rhs
}

func /(rhs: Point3, lhs: Scalar) -> Point3 {
	return (rhs.0/lhs, rhs.1/lhs, rhs.2/lhs)
}

func /=(lhs: inout Point3, rhs: Scalar){
	lhs.0 = lhs.0/rhs
	lhs.1 = lhs.1/rhs
	lhs.2 = lhs.2/rhs
}

func cross(_ lhs: Point3, _ rhs: Point3) -> Point3 {
	return (lhs.1*rhs.2 - lhs.2*rhs.1, lhs.2*rhs.0 - lhs.0*rhs.2, lhs.0*rhs.1 - lhs.1*rhs.0)
}

func dot(_ lhs: Point3, _ rhs: Point3) -> Scalar {
	return lhs.0*rhs.0+lhs.1*rhs.1+lhs.2*rhs.2
}

func norm(_ lhs: Point3) -> Scalar {
	return sqrt(dot(lhs, lhs))
}

func norm2(_ lhs: Point3) -> Scalar {
	return dot(lhs, lhs)
}

func normalize(_ n: Point3) -> Point3 {
	let norm = sqrt(dot(n, n))
	if(norm==0.0){ return n}
	return n/norm
}



*/
/*--Point4--------*/
/*
func +(lhs: Point4, rhs: Point4) -> Point4 {
	return (lhs.0 + rhs.0, lhs.1+rhs.1, lhs.2+rhs.2, lhs.3+rhs.3)
}

func +=(lhs: inout Point4, rhs: Point4) {
	lhs.0 += rhs.0
	lhs.1 += rhs.1
	lhs.2 += rhs.2
	lhs.3 += rhs.3
}

func -(lhs: Point4, rhs: Point4) -> Point4 {
	return (lhs.0 - rhs.0, lhs.1-rhs.1, lhs.2-rhs.2, lhs.3-rhs.3)
}

func -=(lhs: inout Point4, rhs: Point4) {
	lhs.0 -= rhs.0
	lhs.1 -= rhs.1
	lhs.2 -= rhs.2
	lhs.3 -= rhs.3
}

func *(lhs: Scalar, rhs: Point4) -> Point4 {
	return (lhs*rhs.0, lhs*rhs.1, lhs*rhs.2, lhs*rhs.3)
}

func *(rhs: Point4, lhs: Scalar) -> Point4 {
	return (lhs*rhs.0, lhs*rhs.1, lhs*rhs.2, lhs*rhs.3)
}

func *=(lhs: inout Point4, rhs: Scalar){
	lhs.0 = lhs.0*rhs
	lhs.1 = lhs.1*rhs
	lhs.2 = lhs.2*rhs
	lhs.3 = lhs.3*rhs
}

func /(rhs: Point4, lhs: Scalar) -> Point4 {
	return (rhs.0/lhs, rhs.1/lhs, rhs.2/lhs, rhs.3/lhs)
}

func /=(lhs: inout Point4, rhs: Scalar){
	lhs.0 = lhs.0/rhs
	lhs.1 = lhs.1/rhs
	lhs.2 = lhs.2/rhs
	lhs.2 = lhs.3/rhs
}
*/
