//
//  Model.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 13/02/2016.
//  Copyright © 2016 Simon Rodriguez. All rights reserved.
//

import Foundation

import simd

struct Face {
	let v0: InputVertex
	let v1: InputVertex
	let v2: InputVertex
}


struct FaceIndices {
	let v: Int
	let t: Int
	let n: Int
}


final class Mesh {
	
	var vertices: [Vertex] = []
	var normals: [Normal] = []
	var uvs: [UV] = []
	var indices: [(FaceIndices, FaceIndices, FaceIndices)] = []
	var faces: [Face] = []
	
	
	init(path: String, shouldNormalize: Bool = false){
		
		let stringContent = try? String(contentsOfFile: path, encoding: String.Encoding.utf8)
		guard let lines = stringContent?.components(separatedBy: CharacterSet.newlines) else {
			print("Couldn't load the mesh")
			return
		}
		
		for line in lines {
			if (line.hasPrefix("v ")){//Vertex
				var components = line.components(separatedBy: CharacterSet.whitespaces).filter({!$0.isEmpty})
				vertices.append(float3(Scalar(components[1])!, Scalar(components[2])!, Scalar(components[3])!))
			} else if (line.hasPrefix("vt ")) {//UV coords
				var components = line.components(separatedBy: CharacterSet.whitespaces).filter({!$0.isEmpty})
				uvs.append(float2(Scalar(components[1])!, Scalar(components[2])!))
				
			} else if (line.hasPrefix("vn ")) {//Normal coords
				var components = line.components(separatedBy: CharacterSet.whitespaces).filter({!$0.isEmpty})
				normals.append(float3(Scalar(components[1])!, Scalar(components[2])!, Scalar(components[3])!))
			} else if (line.hasPrefix("f ")) {//Face with vertices/uv/normals
				let components = line.components(separatedBy: CharacterSet.whitespaces).filter({!$0.isEmpty})
				
				let splittedComponents = components.map({$0.components(separatedBy: "/")})
				
				let intComps1 = splittedComponents[1].map({ $0 == "" ? 0: Int($0)!})
				let fi1 = FaceIndices(v: intComps1[0]-1, t: intComps1[1]-1, n: intComps1[2]-1)
				let intComps2 = splittedComponents[2].map({ $0 == "" ? 0: Int($0)!})
				let fi2 = FaceIndices(v: intComps2[0]-1, t: intComps2[1]-1, n: intComps2[2]-1)
				let intComps3 = splittedComponents[3].map({ $0 == "" ? 0: Int($0)!})
				let fi3 = FaceIndices(v: intComps3[0]-1, t: intComps3[1]-1, n: intComps3[2]-1)
				indices.append((fi1, fi2, fi3))
				
			}
			
			
		}
		
		if shouldNormalize {
			center()
			normalize()
		}
		
		// Expand indices.
		expand()
		
	}
	
	
	private func center(){
		
		var bary = vertices.reduce(float3(0.0, 0.0, 0.0), { $0 + $1 })
		bary =  (1.0 / Scalar(vertices.count)) * bary
		vertices = vertices.map({ $0 - bary })
		
	}
	
	
	private func normalize(scale: Scalar = 1.0){
		
		var mini = vertices[0]
		var maxi = vertices[0]
		for vert in vertices {
			mini = min(mini, vert)
			maxi = max(maxi, vert)
			/*mini.x = min(mini.x, vert.x)
			mini.y = min(mini.y, vert.y)
			mini.z = min(mini.z, vert.z)
			maxi.x = min(maxi.x, vert.x)
			maxi.y = min(maxi.y, vert.y)
			maxi.z = min(maxi.z, vert.z)*/
		}
		let maxfinal = max(abs(maxi), abs(mini))
		/*let maxy = max(abs(maxi.y), abs(mini.y))
		let maxz = max(abs(maxi.z), abs(mini.z))*/
		//We have the highest distance from the origin, we want it to be smaller than 1
		var truemax = max(maxfinal.x, maxfinal.y, maxfinal.z)
		truemax = truemax == 0 ? 1.0 : truemax/scale
		vertices = vertices.map({ 1.0/truemax * $0 })
		
	}
	
	
	private func expand(){
		
		for (ind1, ind2, ind3) in indices {
			let f = Face(v0: InputVertex(v: vertices[ind1.v], t: uvs[ind1.t], n: normals[ind1.n]),
			             v1: InputVertex(v: vertices[ind2.v], t: uvs[ind2.t], n: normals[ind2.n]),
			             v2: InputVertex(v: vertices[ind3.v], t: uvs[ind3.t], n: normals[ind3.n])
						)
			faces.append(f)
		}
		
	}
}
