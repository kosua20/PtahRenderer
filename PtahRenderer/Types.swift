//
//  Types.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 13/02/2016.
//  Copyright © 2016 Simon Rodriguez. All rights reserved.
//

import Foundation

typealias Scalar = Double
typealias Point3f = (Scalar, Scalar, Scalar)
typealias Point2f = (Scalar, Scalar)
typealias Point2i = (Int, Int)
typealias Vertex = Point3f
typealias Normal = Point3f
typealias UV = Point2f
typealias Color = (UInt8,UInt8,UInt8)
typealias Face = (FaceIndices,FaceIndices,FaceIndices)

func cross(lhs : Point3f,_ rhs : Point3f) -> Point3f {
	return (lhs.1*rhs.2 - lhs.2*rhs.1,lhs.2*rhs.0 - lhs.0*rhs.2,lhs.0*rhs.1 - lhs.1*rhs.0)
}

func dot(lhs : Point3f, _ rhs : Point3f) -> Scalar {
	return lhs.0*rhs.0+lhs.1*rhs.1+lhs.2*rhs.2
}

func normalize(inout n : Point3f){
	let norm = sqrt(dot(n,n))
	if(norm==0.0){ return }
	n /= norm
}

func normalized(n : Point3f) -> Point3f {
	let norm = sqrt(dot(n,n))
	if(norm==0.0){ return n}
	return n/norm
}

func +(lhs : Point2i, rhs : Point2i) -> Point2i {
	return (lhs.0 + rhs.0,lhs.1+rhs.1)
}

func +=(inout lhs : Point2i, rhs : Point2i) {
	lhs.0 += rhs.0
	lhs.1 += rhs.1
}

func -(lhs : Point2i, rhs : Point2i) -> Point2i {
	return (lhs.0 - rhs.0,lhs.1-rhs.1)
}

func -=(inout lhs : Point2i, rhs : Point2i) {
	lhs.0 -= rhs.0
	lhs.1 -= rhs.1
}

func +(lhs : Point3f, rhs : Point3f) -> Point3f {
	return (lhs.0 + rhs.0,lhs.1+rhs.1,lhs.2+rhs.2)
}

func +=(inout lhs : Point3f, rhs : Point3f) {
	lhs.0 += rhs.0
	lhs.1 += rhs.1
	lhs.2 += rhs.2
}
func -(lhs : Point3f, rhs : Point3f) -> Point3f {
	return (lhs.0 - rhs.0,lhs.1-rhs.1,lhs.2-rhs.2)
}

func -=(inout lhs : Point3f, rhs : Point3f) {
	lhs.0 -= rhs.0
	lhs.1 -= rhs.1
	lhs.2 -= rhs.2
}

func *(lhs : Scalar, rhs : Point3f) -> Point3f {
	return (lhs*rhs.0,lhs*rhs.1,lhs*rhs.2)
}

func *(rhs : Point3f, lhs : Scalar) -> Point3f {
	return (lhs*rhs.0,lhs*rhs.1,lhs*rhs.2)
}


func *=(inout lhs : Point3f, rhs : Scalar){
	lhs.0 = lhs.0*rhs
	lhs.1 = lhs.1*rhs
	lhs.2 = lhs.2*rhs
}



func /(rhs : Point3f, lhs : Scalar) -> Point3f {
	return (rhs.0/lhs,rhs.1/lhs,rhs.2/lhs)
}


func /=(inout lhs : Point3f, rhs : Scalar){
	lhs.0 = lhs.0/rhs
	lhs.1 = lhs.1/rhs
	lhs.2 = lhs.2/rhs
}



enum TextureMode {
	case Clamp
	case Wrap
}



struct FaceIndices : Hashable, Equatable {
	var v : Int
	var t : Int
	var n : Int
	var hashValue : Int {
		return "\(v),\(t),\(n)".hash
	}
}

func ==(lhs: FaceIndices, rhs: FaceIndices) -> Bool {
	return (lhs.v == rhs.v && lhs.n == rhs.n && lhs.t == rhs.t)
}

struct Pixel {
	
	var r:UInt8
	var g:UInt8
	var b:UInt8
	var a:UInt8 = 255
	
	var rgb : Color {
		get {
			return (r, g, b)
		}
		set(newRgb) {
			r = newRgb.0
			g = newRgb.1
			b = newRgb.2
		}
	}
	
	init(_ _r: UInt8,_ _g: UInt8,_ _b: UInt8){
		r = _r
		g = _g
		b = _b
	}
	
	init(_ val : UInt8){
		r = val
		g = val
		b = val
	}
	
}