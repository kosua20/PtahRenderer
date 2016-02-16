//
//  Shaders.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 16/02/2016.
//  Copyright © 2016 Simon Rodriguez. All rights reserved.
//

import Foundation

protocol Shader {
	var uniforms : [Texture] { get set }
	func vertexShader(v : Point3) -> Point3
	func fragmentShader(p : Point2) -> Color
}


class TestShader : Protocol {
	func vertexShader(v : Point3) -> Point3{
		return v
	}
	
	func fragmentShader(p : Point2)-> Color{
		return (255,255,255)
	}
}