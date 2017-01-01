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
	
	
	func vertexShader(_ v: Point3) -> Point4 { fatalError("Must Override") }
	
	func fragmentShader(_ p: Point2) -> Color { fatalError("Must Override") }
	
	func register(name: String, value: Texture) { textures[name] = value }
	
	func register(name: String, value: Matrix4) { matrices[name] = value }
	
	func register(name: String, value: Point4) { points4[name] = value }
	
	func register(name: String, value: Point3) { points3[name] = value }
	
	func register(name: String, value: Point2) { points2[name] = value }
	
	func register(name: String, value: Scalar) { scalars[name] = value }
	
	func register(name: String, value: Any) { others[name] = value }
}


class TestProgram: Program {
	
	override func vertexShader(_ v: Point3) -> Point4 {
		return matrices["mvp"]! * (v.0, v.1, v.2, 1.0)
	}
	
	override func fragmentShader(_ p: Point2)-> Color{
		return (textures["texture"]!)[p.0, p.1].rgb
	}
	
}
