//
//  Pixel.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 13/02/2016.
//  Copyright © 2016 Simon Rodriguez. All rights reserved.
//

import Foundation

import simd


typealias Color = (UInt8, UInt8, UInt8)


/*-- Color---------*/

func *(lhs: Scalar, rhs: Color) -> Color {

	let r = clamp(lhs*Scalar(rhs.0),0,255)
	let g = clamp(lhs*Scalar(rhs.1),0,255)
	let b = clamp(lhs*Scalar(rhs.2),0,255)
	return (UInt8(r), UInt8(g), UInt8(b))

}


func *(rhs: Color, lhs: Scalar) -> Color {

	return lhs*rhs

}


func /(lhs: Color, rhs: Scalar) -> Color {

	return (UInt8(Scalar(lhs.0)/rhs), UInt8(Scalar(lhs.1)/rhs), UInt8(Scalar(lhs.2)/rhs))

}


func +(rhs: Color, lhs: Color) -> Color {
	
	let r = clamp(Scalar(rhs.0)+Scalar(lhs.0),0,255)
	let g = clamp(Scalar(rhs.1)+Scalar(lhs.1),0,255)
	let b = clamp(Scalar(rhs.2)+Scalar(lhs.2),0,255)
	return (UInt8(r), UInt8(g), UInt8(b))
	
}


/*--Pixel-----------*/

struct Pixel {
	
	var r:UInt8
	var g:UInt8
	var b:UInt8
	var a:UInt8 = 255
	
	
	var rgb: Color {
		get {
			return (r, g, b)
		}
		set(newRgb) {
			r = newRgb.0
			g = newRgb.1
			b = newRgb.2
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





