//
//  Model.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 13/02/2016.
//  Copyright © 2016 Simon Rodriguez. All rights reserved.
//

import Foundation



class Model {
	var vertices : [Vertex] = []
	var normals : [Normal] = []
	var uvs : [UV] = []
	var faces : [Face] = []
	
	init(path : String){
		let stringContent = try? String(contentsOfFile: path)
		guard let lines = stringContent?.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()) else {
			print("Couldn't load the mesh")
			return
		}
		
		for line in lines {
			if (line.hasPrefix("v ")){//Vertex
				var components = line.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).filter({!$0.isEmpty})
				vertices.append((Scalar(components[1])!,Scalar(components[2])!,Scalar(components[3])!))
			} else if (line.hasPrefix("vt ")) {//UV coords
				var components = line.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).filter({!$0.isEmpty})
				uvs.append((Scalar(components[1])!,Scalar(components[2])!))
				
			} else if (line.hasPrefix("vn ")) {//Normal coords
				var components = line.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).filter({!$0.isEmpty})
				normals.append((Scalar(components[1])!,Scalar(components[2])!,Scalar(components[3])!))
			} else if (line.hasPrefix("f ")) {//Face with vertices/uv/normals
				let components = line.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).filter({!$0.isEmpty})
				
				let splittedComponents = components.map({$0.componentsSeparatedByString("/")})
				// print(splittedComponents)
				
				let intComps1 = splittedComponents[1].map({ $0 == "" ? 0 : Int($0)!})
				let fi1 = FaceIndices(v: intComps1[0]-1, t: intComps1[1]-1, n: intComps1[2]-1)
				let intComps2 = splittedComponents[2].map({ $0 == "" ? 0 : Int($0)!})
				let fi2 = FaceIndices(v: intComps2[0]-1, t: intComps2[1]-1, n: intComps2[2]-1)
				let intComps3 = splittedComponents[3].map({ $0 == "" ? 0 : Int($0)!})
				let fi3 = FaceIndices(v: intComps3[0]-1, t: intComps3[1]-1, n: intComps3[2]-1)
				faces.append((fi1,fi2,fi3))
				
			}
			
			
		}
	}
	
	func center(){
		var bary = vertices.reduce((0.0,0.0,0.0), combine: {($0.0+$1.0,$0.1+$1.1,$0.2+$1.2)})
		bary.0 /= Scalar(vertices.count)
		bary.1 /= Scalar(vertices.count)
		bary.2 /= Scalar(vertices.count)
		vertices = vertices.map({($0.0 - bary.0,$0.1 - bary.1,$0.2 - bary.2)})
	}
	
	func normalize(scale : Double = 1.0){
		var mini = vertices[0]
		var maxi = vertices[0]
		for vert in vertices {
			mini.0 = min(mini.0, vert.0)
			mini.1 = min(mini.1, vert.1)
			mini.2 = min(mini.2, vert.2)
			maxi.0 = min(maxi.0, vert.0)
			maxi.1 = min(maxi.1, vert.1)
			maxi.2 = min(maxi.2, vert.2)
		}
		let maxx = max(abs(maxi.0),abs(mini.0))
		let maxy = max(abs(maxi.1),abs(mini.1))
		let maxz = max(abs(maxi.2),abs(mini.2))
		//We have the highest distance from the origin, we want it to be smaller than 1
		var truemax = max(maxx,maxy,maxz)
		truemax = truemax == 0 ? 1.0 : truemax/scale
	
		
		vertices = vertices.map({($0.0/truemax,$0.1/truemax,$0.2/truemax)})
	
	}
}







	


