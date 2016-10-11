//
//  Types.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 13/02/2016.
//  Copyright © 2016 Simon Rodriguez. All rights reserved.
//

import Foundation

typealias Scalar = Double
typealias Color = (UInt8,UInt8,UInt8)



/*-- Color---------*/

func *(lhs : Scalar, rhs : Color) -> Color {
	return (UInt8(lhs*Scalar(rhs.0)),UInt8(lhs*Scalar(rhs.1)),UInt8(lhs*Scalar(rhs.2)))
}

func *(rhs : Color, lhs : Scalar) -> Color {
	return lhs*rhs
}

func /(lhs : Color, rhs : Scalar) -> Color {
	return (UInt8(Scalar(lhs.0)/rhs),UInt8(Scalar(lhs.1)/rhs),UInt8(Scalar(lhs.2)/rhs))
}



/*--Pixel-----------*/

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
	
	init(_ _r: UInt8,_ _g: UInt8,_ _b: UInt8, _ _a: UInt8){
		r = _r
		g = _g
		b = _b
		a = _a
	}
	
	init(_ val : UInt8){
		r = val
		g = val
		b = val
	}
}

enum TextureMode {
	case clamp
	case wrap
}

struct Face {
	var v : [Vertex]
	var t : [UV]
	var n : [Normal]
}

struct FaceIndices {
	var v : Int
	var t : Int
	var n : Int
}

