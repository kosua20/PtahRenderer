//
//  Shaders.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 16/02/2016.
//  Copyright © 2016 Simon Rodriguez. All rights reserved.
//

import Foundation

class Program  {
	
	private(set) public var textures: [String : Texture] = [:]
	private(set) public var matrices: [String : Matrix4] = [:]
	private(set) public var points4: [String : Point4] = [:]
	private(set) public var points3: [String : Point3] = [:]
	private(set) public var points2: [String : Point2] = [:]
	private(set) public var scalars: [String : Scalar] = [:]
	private(set) public var buffers: [String : ScalarTexture] = [:]
	private(set) public var others: [String : Any] = [:]
	
	func vertexShader(_ input: InputVertex) -> OutputVertex { fatalError("Must Override") }
	
	func fragmentShader(_ input: InputFragment) -> Color? { fatalError("Must Override") }
	
	func register(name: String, value: Texture) { textures[name] = value }
	
	func register(name: String, value: Matrix4) { matrices[name] = value }
	
	func register(name: String, value: Point4) { points4[name] = value }
	
	func register(name: String, value: Point3) { points3[name] = value }
	
	func register(name: String, value: Point2) { points2[name] = value }
	
	func register(name: String, value: Scalar) { scalars[name] = value }
	
	func register(name: String, value: ScalarTexture) { buffers[name] = value }
	
	func register(name: String, value: Any) { others[name] = value }

}





