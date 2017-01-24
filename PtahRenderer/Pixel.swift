//
//  Pixel.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 13/02/2016.
//  Copyright © 2016 Simon Rodriguez. All rights reserved.
//

import Foundation

import simd


typealias Color = Point3



/*--Pixel-----------*/

struct Pixel {
	
	var r:UInt8
	var g:UInt8
	var b:UInt8
	var a:UInt8 = 255
	
	
	var rgb: Color {
		get {
			return Color(Scalar(r)/255.0, Scalar(g)/255.0, Scalar(b)/255.0)
		}
		set(newColor) {
			r = UInt8(clamp(newColor.x*255, 0, 255))
			g = UInt8(clamp(newColor.y*255, 0, 255))
			b = UInt8(clamp(newColor.z*255, 0, 255))
		}
	}
	
	
	init(_ _r: UInt8, _ _g: UInt8, _ _b: UInt8){
		r = _r
		g = _g
		b = _b
	}
	
	
	init(_ _r: UInt8, _ _g: UInt8, _ _b: UInt8, _ _a: UInt8){
		r = _r
		g = _g
		b = _b
		a = _a
	}
	
	
	init(_ val: UInt8){
		r = val
		g = val
		b = val
	}
	
}


func *(lhs: Scalar, rhs: Pixel) -> Pixel {
	
	let r = clamp(lhs * Scalar(rhs.r), 0, 255)
	let g = clamp(lhs * Scalar(rhs.g), 0, 255)
	let b = clamp(lhs * Scalar(rhs.b), 0, 255)
	let a = clamp(lhs * Scalar(rhs.a), 0, 255)
	return Pixel(UInt8(r), UInt8(g), UInt8(b), UInt8(a))
	
}

func +(lhs: Pixel, rhs: Pixel) -> Pixel {
	
	let r = clamp(lhs.r + rhs.r, 0, 255)
	let g = clamp(lhs.g + rhs.g, 0, 255)
	let b = clamp(lhs.b + rhs.b, 0, 255)
	let a = clamp(lhs.a + rhs.a, 0, 255)
	return Pixel(r, g, b, a)
	
}





