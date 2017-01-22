//
//  Types.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 13/02/2016.
//  Copyright © 2016 Simon Rodriguez. All rights reserved.
//

import Foundation

typealias Scalar = Float
typealias Color = (UInt8, UInt8, UInt8)



/*-- Color---------*/

func *(lhs: Scalar, rhs: Color) -> Color {
	return (UInt8(lhs*Scalar(rhs.0)), UInt8(lhs*Scalar(rhs.1)), UInt8(lhs*Scalar(rhs.2)))
}

func *(rhs: Color, lhs: Scalar) -> Color {
	return lhs*rhs
}

func /(lhs: Color, rhs: Scalar) -> Color {
	return (UInt8(Scalar(lhs.0)/rhs), UInt8(Scalar(lhs.1)/rhs), UInt8(Scalar(lhs.2)/rhs))
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

func clamp(_ x: Scalar, _ a: Scalar, _ b: Scalar) -> Scalar {
	return min(b, max(a, x))
}

func clamp(_ x: UInt8, _ a: UInt8, _ b: UInt8) -> UInt8 {
	return min(b, max(a, x))
}

func clamp(_ x: Int, _ a: Int, _ b: Int) -> Int {
	return min(b, max(a, x))
}

func ==(_ x: OutputVertex, _ y: OutputVertex) -> Bool {
	// Ignore 'others' attribute.
	return x.v == y.v && x.n == y.n && x.t == y.t
}

func !=(_ x: OutputVertex, _ y: OutputVertex) -> Bool {
	// Ignore 'others' attribute.
	return x.v != y.v || x.n != y.n || x.t != y.t
}

struct InputVertex {
	let v: Vertex
	let t: UV
	let n: Normal
}

struct OutputVertex {
	var v: Point4
	var t: UV
	var n: Normal
	var others : [Scalar]
}

struct OutputFace {
	let v0: OutputVertex
	let v1: OutputVertex
	let v2: OutputVertex
}

struct InputFragment {
	let n: Normal
	let t: UV
	let others: [Scalar]
}

struct Face {
	let v0: InputVertex
	let v1: InputVertex
	let v2: InputVertex
}

struct FaceIndices {
	let v: Int
	let t: Int
	let n: Int
}

