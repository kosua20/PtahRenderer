//
//  Shaders.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 16/02/2016.
//  Copyright © 2016 Simon Rodriguez. All rights reserved.
//

import Foundation

class Program  {
	
	fileprivate var others: [String : Any] = [:]
	fileprivate var textures: [String : Texture] = [:]
	fileprivate var matrices: [String : Matrix4] = [:]
	fileprivate var points4: [String : Point4] = [:]
	fileprivate var points3: [String : Point3] = [:]
	fileprivate var points2: [String : Point2] = [:]
	fileprivate var scalars: [String : Scalar] = [:]
	
	
	func vertexShader(_ v: InputVertex) -> OutputVertex { fatalError("Must Override") }
	
	func fragmentShader(_ p: InputFragment) -> Color { fatalError("Must Override") }
	
	func register(name: String, value: Texture) { textures[name] = value }
	
	func register(name: String, value: Matrix4) { matrices[name] = value }
	
	func register(name: String, value: Point4) { points4[name] = value }
	
	func register(name: String, value: Point3) { points3[name] = value }
	
	func register(name: String, value: Point2) { points2[name] = value }
	
	func register(name: String, value: Scalar) { scalars[name] = value }
	
	func register(name: String, value: Any) { others[name] = value }
}


class DefaultProgram: Program {
	
	override func vertexShader(_ input: InputVertex) -> OutputVertex {
		let position = matrices["mvp"]! * (input.v.0, input.v.1, input.v.2, 1.0)
		return OutputVertex(v: position, t: input.t, n: input.n, others: [])
	}
	
	override func fragmentShader(_ input: InputFragment)-> Color{
		//let col = normalized(input.n)*Scalar(0.5)+(0.5,0.5,0.5)
		//return (UInt8(255.0 * col.0), UInt8(255.0 * col.1), UInt8(255.0 * col.2))
		return (textures["texture"]!)[input.t.0, input.t.1].rgb
	}
	
}

class SkyboxProgram: Program {
	
	override func vertexShader(_ input: InputVertex) -> OutputVertex {
		let position = matrices["mvp"]! * (input.v.0, input.v.1, input.v.2, 1.0)
		return OutputVertex(v: position, t: input.t, n: input.n, others: [])
	}
	
	override func fragmentShader(_ p: InputFragment)-> Color{
		let tex = textures["texture"]!
		return (0,128,0)//tex[p.0, p.1].rgb
	}
	
}
