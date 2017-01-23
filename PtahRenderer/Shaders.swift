//
//  Shaders.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 23/01/2017.
//  Copyright © 2017 Simon Rodriguez. All rights reserved.
//

import Foundation

class DefaultProgram: Program {
	
	override func vertexShader(_ input: InputVertex) -> OutputVertex {
		let position = matrices["mvp"]! * (input.v.0, input.v.1, input.v.2, 1.0)
		let normal = matrices["invmv"]! * (input.n.0, input.n.1, input.n.2, 0.0)
		return OutputVertex(v: position, t: input.t, n: (normal.0, normal.1, normal.2), others: [])
	}
	
	override func fragmentShader(_ input: InputFragment)-> Color! {
		let lighting = max(0.0, dot(normalized(input.n), -1.0*points3["lightDir"]!))
		let diffuse = (textures["texture"]!)[input.t.0, input.t.1].rgb
		return lighting * diffuse
	}
	
}

class SkyboxProgram: Program {
	
	override func vertexShader(_ input: InputVertex) -> OutputVertex {
		let position = matrices["mvp"]! * (input.v.0, input.v.1, input.v.2, 1.0)
		return OutputVertex(v: position, t: input.t, n: input.n, others: [])
	}
	
	override func fragmentShader(_ input: InputFragment)-> Color {
		return (textures["texture"]!)[input.t.0, input.t.1].rgb
	}
	
}


class DepthProgram: Program {
	
	override func vertexShader(_ input: InputVertex) -> OutputVertex {
		let position = matrices["mvp"]! * (input.v.0, input.v.1, input.v.2, 1.0)
		return OutputVertex(v: position, t: input.t, n: input.n, others: [abs(position.2)])
	}
	
	override func fragmentShader(_ input: InputFragment)-> Color! {
		return (UInt8(255*input.others[0]*2.0),0,0)
	}
	
}

class NormalVisualizationProgram: Program {
	
	override func vertexShader(_ input: InputVertex) -> OutputVertex {
		let position = matrices["mvp"]! * (input.v.0, input.v.1, input.v.2, 1.0)
		return OutputVertex(v: position, t: input.t, n: input.n, others: [])
	}
	
	override func fragmentShader(_ input: InputFragment)-> Color {
		let col = normalized(input.n)*Scalar(0.5)+(0.5,0.5,0.5)
		return (UInt8(255.0 * col.0), UInt8(255.0 * col.1), UInt8(255.0 * col.2))
	}
	
}
