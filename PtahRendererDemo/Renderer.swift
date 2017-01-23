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
	
	private var time : Scalar = 0.0
	private var camera: Camera
	private let lightDir: Point4 = (-0.57735, -0.57735, -0.57735, 0.0)
	private let vpLight : Matrix4
	private let dragon: Object
	private let floor: Object
	private let monkey: Object
	private let cubemap: Object
	
	
	init(width _width: Int, height _height: Int){
		width = _width
		height = _height
		
		internalRenderer = InternalRenderer(width: width, height: height)
		//internalRenderer.mode = .wireframe
		internalRenderer.addFramebuffer(width: 128, height: 128)
		
		var baseName = "dragon"
		dragon = Object(meshPath: rootDir + "models/" + baseName + ".obj", textureNames: ["texture"], texturePaths: [rootDir + "textures/" + baseName + ".png"])
		baseName = "floor"
		floor = Object(meshPath: rootDir + "models/" + baseName + ".obj"
			, textureNames: ["texture"], texturePaths: [rootDir + "textures/" + baseName + ".png"])
		baseName = "monkey"
		monkey = Object(meshPath: rootDir + "models/" + baseName + ".obj"
			, textureNames: ["texture"], texturePaths: [rootDir + "textures/" + baseName + ".png"])
		baseName = "cubemap"
		cubemap = Object(meshPath: rootDir + "models/" + baseName + ".obj", program: SkyboxProgram()
			, textureNames: ["texture"], texturePaths: [rootDir + "textures/" + baseName + ".png"])
		
		dragon.model =  Matrix4.translationMatrix((-0.25,0.1,-0.25)) * Matrix4.scaleMatrix(0.75)
		floor.model = Matrix4.translationMatrix((0.0,-0.5,0.0)) * Matrix4.scaleMatrix(2.0)
		monkey.model =  Matrix4.translationMatrix((0.5,0.0,0.5)) * Matrix4.scaleMatrix(0.5)
		cubemap.model = Matrix4.scaleMatrix(5.0)
		
		let proj = Matrix4.perspectiveMatrix(fov:70.0, aspect: Scalar(width)/Scalar(height), near: 0.5, far: 10.0)
		let initialPos = 2.0*normalized((0.0, 0.5, 1.0))
		camera = Camera(position: initialPos, center: (0.0, 0.0, 0.0), up: (0.0, 1.0, 0.0), projection: proj)
		
		vpLight = Matrix4.orthographicMatrix(right: 2.0, top: 2.0, near: 0.1, far: 100.0) *  Matrix4.lookAtMatrix(eye: (-lightDir.0, -lightDir.1, -lightDir.2), target: (0.0,0.0,0.0), up: (0.0,1.0,0.0))
		
	}
	
	
	func update(elapsed: Scalar){
		let theta : Float = 3.14159*time*0.1
		camera.position =  2.0*normalized((cos(theta), 0.5, sin(theta)))
		camera.update()
		let vp = camera.projection*camera.view
		let lightViewDir4 = camera.view * lightDir
		let lightViewDir = normalized((lightViewDir4.0, lightViewDir4.1, lightViewDir4.2))
		
		
		let mvpDragon = vp*dragon.model
		let invMVDragon = inverse(transpose(camera.view * dragon.model))
		let mvpLightDragon = vpLight*dragon.model
		dragon.program.register(name: "mvp", value: mvpDragon)
		dragon.program.register(name: "invmv", value: invMVDragon)
		dragon.program.register(name: "lightDir", value: lightViewDir)
		dragon.depthProgram.register(name: "mvp", value: mvpLightDragon)
		dragon.program.register(name: "lightMvp", value: mvpLightDragon)
		
		let mvpFloor = vp*floor.model
		let invMVFloor = inverse(transpose(camera.view * floor.model))
		let mvpLightFloor = vpLight*floor.model
		
		floor.program.register(name: "mvp", value: mvpFloor)
		floor.program.register(name: "invmv", value: invMVFloor)
		floor.program.register(name: "lightDir", value: lightViewDir)
		floor.depthProgram.register(name: "mvp", value: mvpLightFloor)
		floor.program.register(name: "lightMvp", value: mvpLightFloor)
		
		monkey.model = Matrix4.translationMatrix((0.5,0.0,0.5)) * Matrix4.scaleMatrix(0.4) * Matrix4.rotationMatrix(angle: time, axis: (0.0,1.0,0.0))
		let mvpMonkey = vp*monkey.model
		let invMVMonkey = inverse(transpose(camera.view * monkey.model))
		let mvpLightMonkey = vpLight*monkey.model
		monkey.program.register(name: "mvp", value: mvpMonkey)
		monkey.program.register(name: "invmv", value: invMVMonkey)
		monkey.program.register(name: "lightDir", value: lightViewDir)
		monkey.depthProgram.register(name: "mvp", value: mvpLightMonkey)
		monkey.program.register(name: "lightMvp", value: mvpLightMonkey)
		
		let mvpCubemap = vp*cubemap.model
		cubemap.program.register(name: "mvp", value: mvpCubemap)
	}
	
	func render(elapsed: Scalar){
		time += elapsed
		update(elapsed:elapsed)
		
		internalRenderer.bindFramebuffer(i: 1)
		internalRenderer.clear(color: false, depth: true)
		internalRenderer.drawMesh(mesh: monkey.mesh, program: monkey.depthProgram, depthOnly: true)
		internalRenderer.drawMesh(mesh: dragon.mesh, program: dragon.depthProgram, depthOnly: true)
		internalRenderer.drawMesh(mesh: floor.mesh, program: floor.depthProgram, depthOnly: true)
		
		let depthMap = ScalarTexture(buffer: internalRenderer.flushDepthBuffer(), width: internalRenderer.width, height: internalRenderer.height)
		floor.program.register(name: "zbuffer", value: depthMap)
		monkey.program.register(name: "zbuffer", value: depthMap)
		dragon.program.register(name: "zbuffer", value: depthMap)
		
		internalRenderer.bindFramebuffer(i: 0)
		internalRenderer.clear(color: false, depth: true)
		internalRenderer.drawMesh(mesh: monkey.mesh, program: monkey.program)
		internalRenderer.drawMesh(mesh: dragon.mesh, program: dragon.program)
		internalRenderer.drawMesh(mesh: floor.mesh, program: floor.program)
		internalRenderer.drawMesh(mesh: cubemap.mesh, program: cubemap.program)
		//internalRenderer.bindFramebuffer(i: 1)
		/*let bb = internalRenderer.flushDepthBuffer()
		var bbmin = bb[0]
		var bbmax = bb[0]
		for b in bb {
			if b < bbmin {
				bbmin = b
			}
			if b > bbmax {
				bbmax = b
			}
		}
		print(bbmin, bbmax)*/
	//	internalRenderer.bindFramebuffer(i: 1)
		
	}
	
	func flush() -> NSImage {
		return internalRenderer.flushImage()
	}
	
}
