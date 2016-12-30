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
	var position : Vertex
	var center : Vertex
	var up : Vertex
	var projection : Matrix4
}


final class Renderer {
	
	private var width = 256
	private var height = 256
	
	private var internalRenderer : InternalRenderer
	
	private var tex : Texture
	private var mesh : Mesh
	private var time = 0.0
	private var camera : Camera
	
	
	init(width _width : Int,height _height : Int){
		width = _width
		height = _height
		
		internalRenderer = InternalRenderer(width: width, height: height)
		
		tex = Texture(path: rootDir + "textures/floor.png")
		mesh = Mesh(path: rootDir + "models/floor.obj", shouldNormalize : true)
		
		let proj = Matrix4.perspectiveMatrix(fov:70.0, aspect: Scalar(width)/Scalar(height), near: 0.01, far: 30.0)
		let initialPos = 2*normalized((1.0,0.5,0.0))
		camera = Camera(position: initialPos, center: (0.0,0.0,0.0), up: (0.0,1.0,0.0), projection: proj)
		mvp = Matrix4()
	}
	
	func vshader(v : [Vertex], uniforms : ) -> [Point4] {
		return v.map({ mvp * ($0.0,$0.1,$0.2,1.0) })
	}
	
	func fshader(uv : UV, texture : Texture) -> Color {
		return texture[uv.0,uv.1].rgb
	}
	
		
	fileprivate var mvp : Matrix4
	
	func update(elapsed : Double){
		let theta = 2.0*time
		camera.position = 2 * normalized((cos(theta),/*0.0*sin(theta)*/ 0.5,sin(theta)))
	}
	
	func render(elapsed : Double){
		time += elapsed
		update(elapsed:elapsed)
		let view = Matrix4.lookAtMatrix(eye: camera.position, target: camera.center, up: camera.up)
		
		mvp = camera.projection*view

		internalRenderer.clear()
		
		
		

		
		
		internalRenderer.drawMesh(mesh,mvp: mvp, texture: tex, vertexShader: vshader, fragmentShader:  fshader)
		
		//drawTest()
		
	}
	
	
	
	func flush() -> NSImage {
		return internalRenderer.flushImage()
	}
	
}
