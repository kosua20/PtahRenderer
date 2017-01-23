//
//  Object.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 31/12/2016.
//  Copyright © 2016 Simon Rodriguez. All rights reserved.
//

import Foundation

class Object {
	
	let mesh: Mesh
	let program: Program
	let depthProgram: Program
	var model: Matrix4 = Matrix4()
	
	init(meshPath: String, program: Program, textureNames: [String], texturePaths: [String]) {
		
		self.mesh = Mesh(path: meshPath, shouldNormalize: true)
		self.program = program
		self.depthProgram = DepthProgram()
		
		for i in 0..<min(textureNames.count, texturePaths.count) {
			let texture = Texture(path: texturePaths[i])
			program.register(name: textureNames[i], value: texture)
		}
		
	}
	
}
