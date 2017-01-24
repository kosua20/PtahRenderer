//
//  Shaders.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 23/01/2017.
//  Copyright © 2017 Simon Rodriguez. All rights reserved.
//

import Foundation
import simd

class ObjectProgram: Program {
	
	
	override func vertexShader(_ input: InputVertex) -> OutputVertex {
		
		// Position and normals conversions.
		let input4 = Point4(input.v, 1.0)
		let position = matrices["mvp"]! * input4
		let normal = matrices["invmv"]! * Point4(input.n, 0.0)
		let lightSpacePosition = matrices["lightMvp"]! * input4
		let viewSpacePosition = matrices["mv"]! * input4
		
		// Output. 'others' contains a 4-components light space position and a 3-components view space position.
		return OutputVertex(v: position, t: input.t, n: Point3(normal),
		                    others: [lightSpacePosition.x, lightSpacePosition.y, lightSpacePosition.z, lightSpacePosition.w,
		                             viewSpacePosition.x, viewSpacePosition.y, viewSpacePosition.z])
	
	}
	
	
	override func fragmentShader(_ input: InputFragment)-> Color! {
		
		// Normal and light reversed direction (already normalized)
		let n = normalize(input.n)
		let d = points3["lightDir"]!
		
		// Diffuse component cos(normal, light direction)
		let diffuseFactor = max(0.0, -dot(n, d))
		let diffuseColor = (textures["texture"]!)[input.t.x, input.t.y].rgb
		
		// Specular: Phong model.
		let specularFactor : Scalar
		if diffuseFactor > 0.0 {
			let r = reflect(d,n: n)
			let v = normalize(-Point3(input.others[4],input.others[5],input.others[6]))
			specularFactor = pow(max(0.0, dot(r,v)), 64)
		} else {
			specularFactor = 0.0
		}
		// White light.
		let specularColor : Color = (UInt8(255), UInt8(255), UInt8(255))
		
		// Shadow. Get coordinates in NDC space, extract depth.
		
		let ndcCoords = (1.0 / input.others[3]) * Point3(input.others[0], input.others[1], input.others[2])
		let currentDepth = ndcCoords.z;
		// Read the corresponding depth in the depth map.
		// We have to flip the texture vertically.
		
		let closestDepth = (buffers["zbuffer"]!)[ndcCoords.x*0.5+0.5, 0.5-ndcCoords.y*0.5]
		// The fragment is in the shadow if it is further away from the light than the surface in the depth map.
		// We introduce a bias factor to mitigate acnee.
		let shadow : Scalar = (currentDepth - closestDepth) < 0.005  ? 1.0 : 0.0;
		
		// ambient + diffuse + specular, with an ambient color derived from the diffuse color.
		return (0.25 + shadow * diffuseFactor) * diffuseColor + shadow * specularFactor * specularColor
	
	}
	
	
}


class SkyboxProgram: Program {
	
	
	override func vertexShader(_ input: InputVertex) -> OutputVertex {
	
		let position = matrices["mvp"]! * Point4(input.v, 1.0)
		return OutputVertex(v: position, t: input.t, n: input.n, others: [])
	
	}
	
	
	override func fragmentShader(_ input: InputFragment)-> Color {
		
		return (textures["texture"]!)[input.t.x, input.t.y].rgb
	
	}
	
	
}


class DepthProgram: Program {
	
	
	override func vertexShader(_ input: InputVertex) -> OutputVertex {
	
		let position = matrices["mvp"]! * Point4(input.v, 1.0)
		return OutputVertex(v: position, t: input.t, n: input.n, others: [])
	
	}
	
	
	override func fragmentShader(_ input: InputFragment)-> Color! {
		// Fragment shader won't be called.
		return (255,0,0)
		
	}
	
	
}


class NormalVisualizationProgram: Program {
	
	
	override func vertexShader(_ input: InputVertex) -> OutputVertex {
	
		let position = matrices["mvp"]! * Point4(input.v, 1.0)
		return OutputVertex(v: position, t: input.t, n: input.n, others: [])
	
	}
	
	
	override func fragmentShader(_ input: InputFragment)-> Color {
		// Transform the model space normal into a color by scaling/shifting.
		let col = normalize(input.n)*0.5+Point3(0.5)
		return (UInt8(255.0 * col.x), UInt8(255.0 * col.y), UInt8(255.0 * col.z))
	
	}
	
	
}
