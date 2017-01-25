//
//  Renderer.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 29/12/2016.
//  Copyright © 2016 Simon Rodriguez. All rights reserved.
//

import Foundation
import simd

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
	
	public var horizontalAngle: Scalar = 0.0
	public var verticalAngle: Scalar = 0.75
	public var distance: Scalar = 2.0
	
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
		internalRenderer.addFramebuffer(width: 128, height: 128)
		
		// Load models.
		var baseName = "dragon"
		dragon = Object(meshPath: rootDir + "models/" + baseName + "4k.obj", program: ObjectProgram(),
		                textureNames: ["texture"], texturePaths: [rootDir + "textures/" + baseName + ".png"])
		baseName = "floor"
		floor = Object(meshPath: rootDir + "models/" + baseName + ".obj", program: ObjectProgram(),
		               textureNames: ["texture"], texturePaths: [rootDir + "textures/" + baseName + ".png"])
		baseName = "monkey"
		monkey = Object(meshPath: rootDir + "models/" + baseName + "2k.obj", program: ObjectProgram(),
		                textureNames: ["texture"], texturePaths: [rootDir + "textures/" + baseName + ".png"])
		baseName = "cubemap"
		cubemap = Object(meshPath: rootDir + "models/" + baseName + ".obj", program: SkyboxProgram(),
		                 textureNames: ["texture"], texturePaths: [rootDir + "textures/" + baseName + ".png"])
		
		// Define initial model matrices.
		dragon.model =  Matrix4.translationMatrix(Point3(-0.25,0.0,-0.25)) * Matrix4.scaleMatrix(0.75)
		floor.model = Matrix4.translationMatrix(Point3(0.0,-0.5,0.0)) * Matrix4.scaleMatrix(2.0)
		monkey.model =  Matrix4.translationMatrix(Point3(0.5,0.0,0.5)) * Matrix4.scaleMatrix(0.5)
		cubemap.model = Matrix4.scaleMatrix(5.0)
		
		// Projection matrix and camera setting.
		let proj = Matrix4.perspectiveMatrix(fov:70.0, aspect: Scalar(width)/Scalar(height), near: 0.1, far: 10.0)
		let initialPos = distance*normalize(Point3(1.0, 0.5, 0.0))
		camera = Camera(position: initialPos, center: Point3(0.0, 0.0, 0.0), up: Point3(0.0, 1.0, 0.0), projection: proj)
		
		// Light settings: direction and view-projection matrix.
		lightDir = Point4(-0.57735, -0.57735, -0.57735, 0.0)
		vpLight = Matrix4.orthographicMatrix(right: 2.0, top: 2.0, near: 0.1, far: 100.0) *  Matrix4.lookAtMatrix(eye: -Point3(lightDir), target: Point3(0.0,0.0,0.0), up: Point3(0.0,1.0,0.0))
		
	}
	
	
	func update(elapsed: Scalar){
		
		// Update camera position and matrix.
		camera.position =  distance*Point3(cos(horizontalAngle)*cos(verticalAngle),
		                                   sin(verticalAngle),
		                                   sin(horizontalAngle)*cos(verticalAngle))
		camera.update()
		
		// Update light direction in view space.
		let lightViewDir4 = camera.view * lightDir
		let lightViewDir = normalize(Point3(lightViewDir4))
		
		// Dragon matrices.
		let mvDragon = camera.view*dragon.model
		let mvpDragon = camera.projection*mvDragon
		let invMVDragon = mvDragon.transpose.inverse
		let mvpLightDragon = vpLight*dragon.model
		
		dragon.program.register(index: 0, value: mvDragon)
		dragon.program.register(index: 1, value: mvpDragon)
		dragon.program.register(index: 2, value: invMVDragon)
		dragon.program.register(index: 0, value: lightViewDir)
		dragon.program.register(index: 3, value: mvpLightDragon)
		dragon.depthProgram.register(index: 0, value: mvpLightDragon)
		
		// Floor matrices.
		let mvFloor = camera.view*floor.model
		let mvpFloor = camera.projection*mvFloor
		let invMVFloor = mvFloor.transpose.inverse
		let mvpLightFloor = vpLight*floor.model
		
		floor.program.register(index: 0, value: mvFloor)
		floor.program.register(index: 1, value: mvpFloor)
		floor.program.register(index: 2, value: invMVFloor)
		floor.program.register(index: 0, value: lightViewDir)
		floor.program.register(index: 3, value: mvpLightFloor)
		floor.depthProgram.register(index: 0, value: mvpLightFloor)

		// Monkey matrices (only animated object).
		monkey.model = Matrix4.translationMatrix(Point3(0.5,0.0,0.5)) * Matrix4.scaleMatrix(0.4) * Matrix4.rotationMatrix(angle: time, axis: Point3(0.0,1.0,0.0))
		let mvMonkey = camera.view*monkey.model
		let mvpMonkey = camera.projection*mvMonkey
		let invMVMonkey = mvMonkey.transpose.inverse
		let mvpLightMonkey = vpLight*monkey.model
		
		monkey.program.register(index: 0, value: mvMonkey)
		monkey.program.register(index: 1, value: mvpMonkey)
		monkey.program.register(index: 2, value: invMVMonkey)
		monkey.program.register(index: 0, value: lightViewDir)
		monkey.program.register(index: 3, value: mvpLightMonkey)
		monkey.depthProgram.register(index: 0, value: mvpLightMonkey)

		// Cubemap matrix.
		let mvpCubemap = camera.projection*camera.view*cubemap.model
		cubemap.program.register(index: 0, value: mvpCubemap)
		
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
		floor.program.register(index: 0, value: depthMap)
		monkey.program.register(index: 0, value: depthMap)
		dragon.program.register(index: 0, value: depthMap)
		
		// Second pass: draw objects with lighting and shadows. 
		// We avoid clearing the color as the skybox will cover the whole screen.
		internalRenderer.bindFramebuffer(i: 0)
		internalRenderer.clear(color: false, depth: true)
		internalRenderer.drawMesh(mesh: monkey.mesh, program: monkey.program)
		internalRenderer.drawMesh(mesh: dragon.mesh, program: dragon.program)
		internalRenderer.drawMesh(mesh: floor.mesh, program: floor.program)
		internalRenderer.drawMesh(mesh: cubemap.mesh, program: cubemap.program)
		
	}
	
	
	func flush() -> CGImage {
		
		return internalRenderer.flushImage()!
	
	}
	
	
	func flushBuffer() -> [Pixel] {
	
		return internalRenderer.flushBuffer()
	
	}
	
	
}
