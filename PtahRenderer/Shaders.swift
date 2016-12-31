//
//  Shaders.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 16/02/2016.
//  Copyright © 2016 Simon Rodriguez. All rights reserved.
//

import Foundation

class Program  {
	
	var uniforms: [String : Any] = [:]
	var textures: [String : Texture] = [:]
	var matrices: [String : Matrix4] = [:]
	
	func vertexShader(_ v: Point3) -> Point4 { fatalError("Must Override") }
	
	func fragmentShader(_ p: Point2) -> Color { fatalError("Must Override") }
	
	func register(name : String, value : Texture) { textures[name] = value }
	
	func register(name : String, value : Matrix4) { matrices[name] = value }
	
	func register(name : String, value : Any) { uniforms[name] = value }
}


class TestProgram: Program {
	
	override func vertexShader(_ v: Point3) -> Point4 {
		let mvp = matrices["mvp"]!
		return mvp * (v.0, v.1, v.2, 1.0)
	}
	
	override func fragmentShader(_ p: Point2)-> Color{
		return (textures["texture"]!)[p.0, p.1].rgb
	}
	
}
