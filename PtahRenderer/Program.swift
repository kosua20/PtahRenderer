//
//  Shaders.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 16/02/2016.
//  Copyright © 2016 Simon Rodriguez. All rights reserved.
//

import Foundation


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
	let p: (Int, Int, Float)
	let n: Normal
	let t: UV
	let others: [Scalar]
}


class Program  {
	
	internal(set) public var textures: [Texture] = []
	internal(set) public var matrices: [Matrix4] = []
	internal(set) public var points4: [Point4] = []
	internal(set) public var points3: [Point3] = []
	internal(set) public var points2: [Point2] = []
	internal(set) public var scalars: [Scalar] = []
	internal(set) public var buffers: [ScalarTexture] = []
	
	func vertexShader(_ input: InputVertex) -> OutputVertex { fatalError("Must Override") }
	
	func fragmentShader(_ input: InputFragment) -> Color? { fatalError("Must Override") }
	
	func register(index: Int = -1, value: Texture) { if index < 0 { textures.append(value) } else { textures[index] = value } }
	
	func register(index: Int = -1, value: Matrix4) { if index < 0 { matrices.append(value) } else { matrices[index] = value } }
	
	func register(index: Int = -1, value: Point4) { if index < 0 { points4.append(value) } else { points4[index] = value } }
	
	func register(index: Int = -1, value: Point3) { if index < 0 { points3.append(value) } else { points3[index] = value } }
	
	func register(index: Int = -1, value: Point2) { if index < 0 { points2.append(value) } else { points2[index] = value } }
	
	func register(index: Int = -1, value: Scalar) { if index < 0 { scalars.append(value) } else { scalars[index] = value } }
	
	func register(index: Int = -1, value: ScalarTexture) { if index < 0 { buffers.append(value) } else { buffers[index] = value } }

}


func ==(_ x: OutputVertex, _ y: OutputVertex) -> Bool {
	// Ignore 'others' attribute.
	return x.v == y.v && x.n == y.n && x.t == y.t
	
}


func !=(_ x: OutputVertex, _ y: OutputVertex) -> Bool {
	// Ignore 'others' attribute.
	return x.v != y.v || x.n != y.n || x.t != y.t
	
}
