//
//  Shaders.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 23/01/2017.
//  Copyright © 2017 Simon Rodriguez. All rights reserved.
//

import Foundation


class ObjectProgram: Program {
	
	
	override func vertexShader(_ input: InputVertex) -> OutputVertex {
		
		// Position and normals conversions.
		let position = matrices["mvp"]! * (input.v.0, input.v.1, input.v.2, 1.0)
		let normal = matrices["invmv"]! * (input.n.0, input.n.1, input.n.2, 0.0)
		let lightSpacePosition = matrices["lightMvp"]! * (input.v.0, input.v.1, input.v.2, 1.0)
		let viewSpacePosition = matrices["mv"]! * (input.v.0, input.v.1, input.v.2, 1.0)
		
		// Output. 'others' contains a 4-components light space position and a 3-components view space position.
		return OutputVertex(v: position, t: input.t, n: (normal.0, normal.1, normal.2),
		                    others: [lightSpacePosition.0, lightSpacePosition.1, lightSpacePosition.2, lightSpacePosition.3,
		                             viewSpacePosition.0, viewSpacePosition.1, viewSpacePosition.2])
	
	}
	
	
	override func fragmentShader(_ input: InputFragment)-> Color! {
		
		// Normal and light reversed direction (already normalized)
		let n = normalized(input.n)
		let d = points3["lightDir"]!
		
		// Diffuse component cos(normal, light direction)
		let diffuseFactor = max(0.0, -dot(n, d))
		let diffuseColor = (textures["texture"]!)[input.t.0, input.t.1].rgb
		
		// Specular: Phong model.
		let specularFactor : Scalar
		if diffuseFactor > 0.0 {
			let r = reflect(d,n)
			let v = normalized((-input.others[4],-input.others[5],-input.others[6]))
			specularFactor = pow(max(0.0, dot(r,v)), 64)
		} else {
			specularFactor = 0.0
		}
		// White light.
		let specularColor : Color = (UInt8(255), UInt8(255), UInt8(255))
		
		// Shadow. Get coordinates in NDC space, extract depth.
		let ndcCoords = (input.others[0], input.others[1], input.others[2]) / input.others[3]
		let currentDepth = ndcCoords.2;
		// Read the corresponding depth in the depth map.
		// We have to flip the texture vertically.
		let closestDepth = (buffers["zbuffer"]!)[ndcCoords.0*0.5+0.5, 0.5-ndcCoords.1*0.5]
		// The fragment is in the shadow if it is further away from the light than the surface in the depth map.
		// We introduce a bias factor to mitigate acnee.
		let shadow : Scalar = (currentDepth - closestDepth) < 0.005  ? 1.0 : 0.0;
		
		// ambient + diffuse + specular, with an ambient color derived from the diffuse color.
		return (0.25 + shadow * diffuseFactor) * diffuseColor + shadow * specularFactor * specularColor
	
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
		// Fragment shader won't be called.
		return (255,0,0)
		
	}
	
	
}


class NormalVisualizationProgram: Program {
	
	
	override func vertexShader(_ input: InputVertex) -> OutputVertex {
	
		let position = matrices["mvp"]! * (input.v.0, input.v.1, input.v.2, 1.0)
		return OutputVertex(v: position, t: input.t, n: input.n, others: [])
	
	}
	
	
	override func fragmentShader(_ input: InputFragment)-> Color {
		// Transform the model space normal into a color by scaling/shifting.
		let col = normalized(input.n)*Scalar(0.5)+(0.5,0.5,0.5)
		return (UInt8(255.0 * col.0), UInt8(255.0 * col.1), UInt8(255.0 * col.2))
	
	}
	
	
}
