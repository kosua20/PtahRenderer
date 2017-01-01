//
//  Renderer.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 29/12/2016.
//  Copyright © 2016 Simon Rodriguez. All rights reserved.
//

import Foundation

#if os(OSX)
import Cocoa
#endif

#if os (Linux)
let rootDir = NSFileManager.defaultManager().currentDirectoryPath + "/data/"
#else
let rootDir = "/Developer/Graphics/PtahRenderer/data/"
#endif

struct Camera {
	var position: Vertex
	var center: Vertex
	var up: Vertex
	var view: Matrix4
	let projection: Matrix4
	
	init(position: Vertex, center: Vertex, up: Vertex, projection: Matrix4) {
		self.position = position
		self.center = center
		self.up = up
		self.view = Matrix4.lookAtMatrix(eye: position, target: center, up: up)
		self.projection = projection
	}
	
	mutating func update() {
		view = Matrix4.lookAtMatrix(eye: position, target: center, up: up)
	}
}

final class Renderer {
	
	private var width = 256
	private var height = 256
	
	private var internalRenderer: InternalRenderer
	
	private var time = 0.0
	private var camera: Camera
	
	private let dragon: Object
	
	
	init(width _width: Int, height _height: Int){
		width = _width
		height = _height
		
		internalRenderer = InternalRenderer(width: width, height: height)
		//internalRenderer.mode = .wireframe
		
		let baseName = "dragon"
		let texturePath = rootDir + "textures/" + baseName + ".png"
		let modelPath = rootDir + "models/" + baseName + ".obj"
		
		dragon = Object(meshPath: modelPath, textureNames: ["texture"], texturePaths: [texturePath])//
		
		
		let proj = Matrix4.perspectiveMatrix(fov:70.0, aspect: Scalar(width)/Scalar(height), near: 0.01, far: 30.0)
		let initialPos = 2*normalized((1.0, 0.5, 0.0))
		
		
		camera = Camera(position: initialPos, center: (0.0, 0.0, 0.0), up: (0.0, 1.0, 0.0), projection: proj)
	}
	
	
	func update(elapsed: Double){
		let theta = time
		camera.position = 1.8 * normalized((cos(theta), 0.5, sin(theta)))
		camera.update()
	}
	
	func render(elapsed: Double){
		time += elapsed
		update(elapsed:elapsed)
		
		let mvp = camera.projection*camera.view*dragon.model
		dragon.program.register(name: "mvp", value: mvp)
		
		internalRenderer.clear()
		internalRenderer.drawMesh(mesh: dragon.mesh, program: dragon.program)
		
	}
	
	func flush() -> NSImage {
		return internalRenderer.flushImage()
	}
	
}
