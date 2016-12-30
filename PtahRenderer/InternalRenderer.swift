//
//  InternalRenderer.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 13/02/2016.
//  Copyright © 2016 Simon Rodriguez. All rights reserved.
//

import Foundation
#if os(OSX)
	import Cocoa
#endif




final class InternalRenderer {
	
	fileprivate var width = 256
	fileprivate var height = 256
	
	fileprivate var buffer: Framebuffer

	init(width _width: Int, height _height: Int){
		width = _width
		height = _height
		buffer = Framebuffer(width: width, height: height)
	}
	
	/*
	
	
	
	func drawTest(){
		let v0 = (-1.0, -1.0, 0.0, 1.0)
		let v1 = (1.0, -1.0, 0.0, 1.0)
		let v2 = (1.0, 1.0, 0.0, 1.0)
		let view = Matrix4.translationMatrix((0.5, 0.0, 0.0)) * Matrix4.rotationMatrix(0.65, axis: (0.0, 0.0, 1.0)) * Matrix4.scaleMatrix(0.5)
		let v = ([v0, v1, v2].map({view*$0}))
		let halfWidth = Scalar(width)*0.5
		let halfHeight = Scalar(height)*0.5
		
		//Culling
		//Cohen-Sutherland region
		let csr = v.map({ (vv: Point4) -> Int in
			let xbit = (vv.0 < -vv.3 ? 0b1: 0b0) + (vv.0 > vv.3 ? 0b10: 0b0) as Int
			let ybit = (vv.1 < -vv.3 ? 0b100: 0b0) + (vv.1 > vv.3 ? 0b1000: 0b0) as Int
			let zbit = (vv.2 < -vv.3 ? 0b10000: 0b0) + (vv.2 > vv.3 ? 0b100000: 0b0) as Int
			return xbit + ybit + zbit
			})
		print(csr)
		
		if v.filter({$0.1 > $0.3}).count > 0 {
			return
		}
		
		let v_s = v.map({ (floor(($0.0 + 1.0)*halfWidth), floor((-1.0*$0.1 + 1.0)*halfHeight), $0.2)})
		
		//--Fragment
		
		triangle(v_s, (255, 128, 0))
		triangleWire(v_s.map({($0.0, $0.1)}), (255, 255, 255))
	}*/
	
	func drawMesh(mesh: Mesh, vertexShader: ([Vertex], [String : Any]) -> [Point4], fragmentShader: (UV, [String : Any]) -> Color, uniforms : [String : Any]){
		
		let halfWidth = Scalar(width)*0.5
		let halfHeight = Scalar(height)*0.5
		
		
		//--Model space
		for f in mesh.faces {
			
			//--- Vertex shader
			//--View space and clip space
			let v_p1 = vertexShader(f.v, uniforms)
			//---
			
			//--Clipping
			//Clipping up edge
			if v_p1.map({$0.1 > $0.3}).filter({$0}).count > 0 {
				continue
			}
			//More here...
				
			//We will need the perspective factors later on
			let ws = v_p1.map({$0.3})
			
			//--NDC space
			let v_p = v_p1.map({($0.0/$0.3, $0.1/$0.3, -$0.2/$0.3)})
			
			//--Backface culling
			//We compute it manually to avoid using a cross product and extract the 3rd component
			let orientation = (v_p[1].0 - v_p[0].0) * (v_p[2].1 - v_p[0].1) - (v_p[1].1 - v_p[0].1) * (v_p[2].0 - v_p[0].0)
			
			if orientation > 0.0 {
				//--Screen space
				let v_s = v_p.map({ (floor(($0.0 + 1.0)*halfWidth), floor((-1.0*$0.1 + 1.0)*halfHeight), $0.2)})
				
				//--- Shading
				triangle(v_s, ws, f.n, f.t, fragmentShader, uniforms)
				//---
			}
		}
	}
	
	func triangle(_ v: [Vertex], _ w: [Scalar], _ n: [Normal], _ uv: [UV], _ fragmentShader: (UV,  [String : Any]) -> Color, _ uniforms :  [String : Any]){
		let (mini, maxi) = boundingBox(v, width, height)
		
		for x in Int(mini.0)...Int(maxi.0) {
			for y in Int(mini.1)...Int(maxi.1) {
				let bary = barycentre(Point3(Scalar(x), Scalar(y), 0.0), v[0], v[1], v[2])
				if (bary.0 < 0.0 || bary.1 < 0.0 || bary.2 < 0.0){ continue }
				
				var persp = (bary.0/w[0], bary.1/w[1], bary.2/w[2])
				persp = persp / (persp.0 + persp.1 + persp.2)
				//Maybe need to compute the depth with the same interpolation ?
				let z =  v[0].2 * bary.0 + v[1].2 * bary.1 + v[2].2 * bary.2
				
				if (buffer.getDepth(x, y) < z){
					buffer.setDepth(x, y, z)
					let tex = barycentricInterpolation(coeffs: persp, t1: uv[0], t2: uv[1], t3: uv[2])
					//let nor = normalized(barycentricInterpolation(coeffs: bary, t1: n[0], t2: n[1], t3: n[2]))
					//let cosfactor = max(0.0, dot(-1.0*nor, l))
					let color = fragmentShader(tex, uniforms)
					buffer.set(x, y, color)
				}
			}
		}
	}
	
	func triangle(_ v: [Vertex], _ color: Color){
		let (mini, maxi) = boundingBox(v, width, height)
		for x in Int(mini.0)...Int(maxi.0) {
			for y in Int(mini.1)...Int(maxi.1) {
				let bary = barycentre(Point3(Scalar(x), Scalar(y), 0.0), v[0], v[1], v[2])
				if (bary.0 < 0.0 || bary.1 < 0.0 || bary.2 < 0.0){ continue }
				let z =  v[0].2 * bary.0 + v[1].2 * bary.1 + v[2].2 * bary.2
				if (buffer.getDepth(x, y) < z){
					buffer.setDepth(x, y, z)
					buffer.set(x, y, color)
				}
			}
		}
	}
	
	func triangleWire(_ v: [Point2], _ color: Color){
			line(v[0], v[1], color)
			line(v[1], v[2], color)
			line(v[2], v[0], color)
	}

	
	func line(_ a_: Point2, _ b_: Point2, _ color: Color){
		var steep = false
		var a = a_
		var b = b_
		
		//Switch orientation if steep line
		if(abs(a.0 - b.0) < abs(a.1 - b.1)){
			steep = true
			swap(&(a.0), &(a.1))
			swap(&(b.0), &(b.1))
		}
		
		//Order points along x axis
		if(a.0 > b.0){
			swap(&a, &b)
		}
		
		//Precompute
		let diffx = b.0 - a.0
		let diffy = b.1 - a.1
		let shift = b.1 > a.1 ? 1: -1
		
		//Error
		let differror = abs(diffy/diffx)
		var error = 0.0
		
		var y = Int(a.1)
		for x in Int(a.0)...Int(b.0) {
			steep ? buffer.set(y, x, color): buffer.set(x, y, color)
			error += differror
			if(error > 0.5){
				y += shift
				error -= 1.0
			}
		}
	}
	
	func clear(color: Bool = true, depth: Bool = true){
		if(color){
			buffer.clearColor((0, 0, 0))
		}
		if(depth){
			buffer.clearDepth()
		}
	}
	
	func flushBuffer() -> [Pixel] {
		return buffer.pixels
	}
	
	
	//MARK: OSX dependant
	
#if os(OSX)
	
	func flushImage() -> NSImage {
		//startTime = CFAbsoluteTimeGetCurrent();
		let image = buffer.imageFromRGBA32Bitmap()
		//print("[Backing]: \t" + String(format: "%.4fs", CFAbsoluteTimeGetCurrent() - startTime))
		return image
	}
	
#endif
	
}
