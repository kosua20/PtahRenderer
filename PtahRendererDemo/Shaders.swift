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
		let lightSpacePosition = matrices["lightMvp"]! * (input.v.0, input.v.1, input.v.2, 1.0)
		let viewSpacePosition = matrices["mv"]! * (input.v.0, input.v.1, input.v.2, 1.0)

		return OutputVertex(v: position, t: input.t, n: (normal.0, normal.1, normal.2), others: [lightSpacePosition.0, lightSpacePosition.1, lightSpacePosition.2, lightSpacePosition.3, viewSpacePosition.0, viewSpacePosition.1, viewSpacePosition.2])
	}
	
	override func fragmentShader(_ input: InputFragment)-> Color! {
		
		let n = normalized(input.n)
		let d = -1.0*points3["lightDir"]! // Already normalized
		
		
		let lighting = max(0.0, dot(n, d))
		let diffuse = (textures["texture"]!)[input.t.0, input.t.1].rgb
		
		let specular : Scalar
		if lighting > 0.0 {
			let r = reflect(-1.0*d,n)
			let v = normalized((-input.others[4],-input.others[5],-input.others[6]))
			specular = pow(max(0.0, dot(r,v)), 64)
		} else {
			specular = 0.0
		}
		
		let projCoords = (input.others[0], input.others[1], input.others[2]) / input.others[3]
		let closestDepth = (buffers["zbuffer"]!)[projCoords.0*0.5+0.5, 1.0-(projCoords.1*0.5+0.5)]
		let currentDepth = projCoords.2;
		let shadow : Scalar = (currentDepth - closestDepth) < 0.005  ? 1.0 : 0.0;
		
		let ambient : Scalar =  0.25
		let white : Color = (UInt8(255), UInt8(255), UInt8(255))
		let specularColor : Color = specular * white
		return (lighting * shadow + ambient) * diffuse + shadow * specularColor
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
		return OutputVertex(v: position, t: input.t, n: input.n, others: [])
	}
	
	override func fragmentShader(_ input: InputFragment)-> Color! {
		return (255,0,0)
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
