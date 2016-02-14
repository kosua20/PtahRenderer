//
//  Types.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 13/02/2016.
//  Copyright © 2016 Simon Rodriguez. All rights reserved.
//

import Foundation

typealias Scalar = Double
typealias Point3 = (Scalar, Scalar, Scalar)
typealias Point2 = (Scalar, Scalar)
typealias Point2i = (Int, Int)
typealias Vertex = Point3
typealias Normal = Point3
typealias UV = Point2
typealias Color = (UInt8,UInt8,UInt8)
typealias Face = (FaceIndices,FaceIndices,FaceIndices)


enum TextureMode {
	case Clamp
	case Wrap
}

struct Triangle {
	var v1, v2, v3 : Vertex
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