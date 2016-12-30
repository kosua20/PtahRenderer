//
//  Shaders.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 16/02/2016.
//  Copyright © 2016 Simon Rodriguez. All rights reserved.
//

import Foundation

protocol Shader {
	var uniforms: [Texture] { get set }
	static func vertexShader(_ v: Point3) -> Point3
	static func fragmentShader(_ p: Point2) -> Color
}


class TestShader: Shader {
	var uniforms: [Texture] = []
	static func vertexShader(_ v: Point3) -> Point3{
		return v
	}
	
	static func fragmentShader(_ p: Point2)-> Color{
		return (255, 255, 255)
	}
}

func vshader(v: [Vertex], uniforms: [String : Any]) -> [Point4] {
	let mvp = uniforms["mvp"] as! Matrix4
	return v.map({ mvp * ($0.0, $0.1, $0.2, 1.0) })
}

func fshader(uv: UV, uniforms: [String : Any]) -> Color {
	
	return (uniforms["texture"] as! Texture)[uv.0, uv.1].rgb
}
