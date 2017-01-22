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
	
	
	func vertexShader(_ input: InputVertex) -> OutputVertex { fatalError("Must Override") }
	
	func fragmentShader(_ input: InputFragment) -> Color? { fatalError("Must Override") }
	
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
		let normal = matrices["invmv"]! * (input.n.0, input.n.1, input.n.2, 0.0)
		return OutputVertex(v: position, t: input.t, n: (normal.0, normal.1, normal.2), others: [])
	}
	
	override func fragmentShader(_ input: InputFragment)-> Color! {
		let lighting = max(0.0, dot(normalized(input.n), -1.0*points3["lightDir"]!))
		let diffuse = (textures["texture"]!)[input.t.0, input.t.1].rgb
		return lighting * diffuse
	}
	
}

class SkyboxProgram: Program {
	
	override func vertexShader(_ input: InputVertex) -> OutputVertex {
		let position = matrices["mvp"]! * (input.v.0, input.v.1, input.v.2, 1.0)
		return OutputVertex(v: position, t: input.t, n: input.n, others: [])
	}
	
	override func fragmentShader(_ input: InputFragment)-> Color {
		return (textures["texture"]!)[input.t.0, input.t.1].rgb
	}
	
}

class NormalVisualizationProgram: Program {
	
	override func vertexShader(_ input: InputVertex) -> OutputVertex {
		let position = matrices["mvp"]! * (input.v.0, input.v.1, input.v.2, 1.0)
		return OutputVertex(v: position, t: input.t, n: input.n, others: [])
	}
	
	override func fragmentShader(_ input: InputFragment)-> Color {
		let col = normalized(input.n)*Scalar(0.5)+(0.5,0.5,0.5)
		return (UInt8(255.0 * col.0), UInt8(255.0 * col.1), UInt8(255.0 * col.2))
	}
	
}


