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
	
	private var internalRenderer: InternalRenderer
	
	private var time: Scalar = 0.0
	private var camera: Camera
	
	private let lightDir: Point4
	private let vpLight: Matrix4
	
	private let dragon: Object
	private let floor: Object
	private let monkey: Object
	private let cubemap: Object
	
	
	init(width: Int, height: Int){
		
		internalRenderer = InternalRenderer(width: width, height: height)
		//internalRenderer.mode = .wireframe
		// Add framebuffer for shadow mapping.
		internalRenderer.addFramebuffer(width: 256, height: 256)
		
		// Load models.
		var baseName = "dragon"
		dragon = Object(meshPath: rootDir + "models/" + baseName + ".obj", program: ObjectProgram(),
		                textureNames: ["texture"], texturePaths: [rootDir + "textures/" + baseName + ".png"])
		baseName = "floor"
		floor = Object(meshPath: rootDir + "models/" + baseName + ".obj", program: ObjectProgram(),
		               textureNames: ["texture"], texturePaths: [rootDir + "textures/" + baseName + ".png"])
		baseName = "monkey"
		monkey = Object(meshPath: rootDir + "models/" + baseName + ".obj", program: ObjectProgram(),
		                textureNames: ["texture"], texturePaths: [rootDir + "textures/" + baseName + ".png"])
		baseName = "cubemap"
		cubemap = Object(meshPath: rootDir + "models/" + baseName + ".obj", program: SkyboxProgram(),
		                 textureNames: ["texture"], texturePaths: [rootDir + "textures/" + baseName + ".png"])
		
		// Define initial model matrices.
		dragon.model =  Matrix4.translationMatrix((-0.25,0.1,-0.25)) * Matrix4.scaleMatrix(0.75)
		floor.model = Matrix4.translationMatrix((0.0,-0.5,0.0)) * Matrix4.scaleMatrix(2.0)
		monkey.model =  Matrix4.translationMatrix((0.5,0.0,0.5)) * Matrix4.scaleMatrix(0.5)
		cubemap.model = Matrix4.scaleMatrix(5.0)
		
		// Projection matrix and camera setting.
		let proj = Matrix4.perspectiveMatrix(fov:70.0, aspect: Scalar(width)/Scalar(height), near: 0.5, far: 10.0)
		let initialPos = 2.0*normalized((0.0, 0.5, 1.0))
		camera = Camera(position: initialPos, center: (0.0, 0.0, 0.0), up: (0.0, 1.0, 0.0), projection: proj)
		
		// Light settings: direction and view-projection matrix.
		lightDir = (-0.57735, -0.57735, -0.57735, 0.0)
		vpLight = Matrix4.orthographicMatrix(right: 2.0, top: 2.0, near: 0.1, far: 100.0) *  Matrix4.lookAtMatrix(eye: (-lightDir.0, -lightDir.1, -lightDir.2), target: (0.0,0.0,0.0), up: (0.0,1.0,0.0))
		
	}
	
	
	func update(elapsed: Scalar){
		
		// Update camera position and matrix.
		let theta : Float = 3.14159*time*0.1
		camera.position =  2.0*normalized((cos(theta), 0.5, sin(theta)))
		camera.update()
		
		// Update light direction in view space.
		let lightViewDir4 = camera.view * lightDir
		let lightViewDir = normalized((lightViewDir4.0, lightViewDir4.1, lightViewDir4.2))
		
		// Dragon matrices.
		let mvDragon = camera.view*dragon.model
		let mvpDragon = camera.projection*mvDragon
		let invMVDragon = inverse(transpose(mvDragon))
		let mvpLightDragon = vpLight*dragon.model
		
		dragon.program.register(name: "mv", value: mvDragon)
		dragon.program.register(name: "mvp", value: mvpDragon)
		dragon.program.register(name: "invmv", value: invMVDragon)
		dragon.program.register(name: "lightDir", value: lightViewDir)
		dragon.program.register(name: "lightMvp", value: mvpLightDragon)
		dragon.depthProgram.register(name: "mvp", value: mvpLightDragon)
		
		// Floor matrices.
		let mvFloor = camera.view*floor.model
		let mvpFloor = camera.projection*mvFloor
		let invMVFloor = inverse(transpose(mvFloor))
		let mvpLightFloor = vpLight*floor.model
		
		floor.program.register(name: "mv", value: mvFloor)
		floor.program.register(name: "mvp", value: mvpFloor)
		floor.program.register(name: "invmv", value: invMVFloor)
		floor.program.register(name: "lightDir", value: lightViewDir)
		floor.program.register(name: "lightMvp", value: mvpLightFloor)
		floor.depthProgram.register(name: "mvp", value: mvpLightFloor)
		
		// Monkey matrices (only animated object).
		monkey.model = Matrix4.translationMatrix((0.5,0.0,0.5)) * Matrix4.scaleMatrix(0.4) * Matrix4.rotationMatrix(angle: time, axis: (0.0,1.0,0.0))
		let mvMonkey = camera.view*monkey.model
		let mvpMonkey = camera.projection*mvMonkey
		let invMVMonkey = inverse(transpose(mvMonkey))
		let mvpLightMonkey = vpLight*monkey.model
		
		monkey.program.register(name: "mv", value: mvMonkey)
		monkey.program.register(name: "mvp", value: mvpMonkey)
		monkey.program.register(name: "invmv", value: invMVMonkey)
		monkey.program.register(name: "lightDir", value: lightViewDir)
		monkey.program.register(name: "lightMvp", value: mvpLightMonkey)
		monkey.depthProgram.register(name: "mvp", value: mvpLightMonkey)
		
		// Cubemap matrix.
		let mvpCubemap = camera.projection*camera.view*cubemap.model
		cubemap.program.register(name: "mvp", value: mvpCubemap)
		
	}
	
	
	func render(elapsed: Scalar){
		
		// Animation update.
		time += elapsed
		update(elapsed:elapsed)
		
		// First pass: draw depth only from light point of view, for shadow mapping.
		internalRenderer.bindFramebuffer(i: 1)
		internalRenderer.clear(color: false, depth: true)
		internalRenderer.drawMesh(mesh: monkey.mesh, program: monkey.depthProgram, depthOnly: true)
		internalRenderer.drawMesh(mesh: dragon.mesh, program: dragon.depthProgram, depthOnly: true)
		internalRenderer.drawMesh(mesh: floor.mesh, program: floor.depthProgram, depthOnly: true)
		
		// Transfer the resulting depth map to the objects for the second pass.
		let depthMap = ScalarTexture(buffer: internalRenderer.flushDepthBuffer(), width: internalRenderer.width, height: internalRenderer.height)
		floor.program.register(name: "zbuffer", value: depthMap)
		monkey.program.register(name: "zbuffer", value: depthMap)
		dragon.program.register(name: "zbuffer", value: depthMap)
		
		// Second pass: draw objects with lighting and shadows. 
		// We avoid clearing the color as the skybox will cover the whole screen.
		internalRenderer.bindFramebuffer(i: 0)
		internalRenderer.clear(color: false, depth: true)
		internalRenderer.drawMesh(mesh: monkey.mesh, program: monkey.program)
		internalRenderer.drawMesh(mesh: dragon.mesh, program: dragon.program)
		internalRenderer.drawMesh(mesh: floor.mesh, program: floor.program)
		internalRenderer.drawMesh(mesh: cubemap.mesh, program: cubemap.program)
		
	}
	
	
	func flush() -> NSImage {
		
		return internalRenderer.flushImage()
	
	}
	
	
	func flushBuffer() -> [Pixel] {
	
		return internalRenderer.flushBuffer()
	
	}
	
	
}
