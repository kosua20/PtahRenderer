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

enum RenderingMode {
	case wireframe
	case shaded
}

enum CullingMode {
	case backface
	case none
}




final class InternalRenderer {
	
	fileprivate var width = 256
	fileprivate var height = 256
	
	fileprivate var buffer: Framebuffer
	var mode : RenderingMode
	var culling : CullingMode
	
	init(width _width: Int, height _height: Int){
		width = _width
		height = _height
		buffer = Framebuffer(width: width, height: height)
		mode = .shaded
		culling = .backface
	}
	
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

			// Due to the way the rasterizer work, the clipping needs are limited.
			// Indeed, each traingle bounding box is clamped wtr the screen dimensions,
			// Preventing any off-screen fragment evaluation.
			/*let csr = v_p1.map({ (vv: Point4) -> Int in
				let xbit = (vv.0 < -vv.3 ? 0b1: 0b0) + (vv.0 > vv.3 ? 0b10: 0b0)// as Int
				let ybit = (vv.1 < -vv.3 ? 0b100: 0b0) + (vv.1 > vv.3 ? 0b1000: 0b0)// as Int
				let zbit = (vv.2 < -vv.3 ? 0b10000: 0b0) + (vv.2 > vv.3 ? 0b100000: 0b0)// as Int
				return xbit + ybit + zbit
			})
			if csr.reduce(1,&) > 0 {
				continue
			}*/
				
			//We will need the perspective factors later on
			let ws = v_p1.map({$0.3})
			
			//--NDC space
			let v_p = v_p1.map({($0.0/$0.3, $0.1/$0.3, -$0.2/$0.3)})
			
			//--Backface culling
			//We compute it manually to avoid using a cross product and extract the 3rd component
			let orientation = (culling == .backface) ? (v_p[1].0 - v_p[0].0) * (v_p[2].1 - v_p[0].1) - (v_p[1].1 - v_p[0].1) * (v_p[2].0 - v_p[0].0) : 1.0
			
			if orientation > 0.0 {
				//--Screen space
				let v_s = v_p.map({ (floor(($0.0 + 1.0)*halfWidth), floor((-1.0*$0.1 + 1.0)*halfHeight), $0.2)})
				
				//--- Shading
				if mode == .shaded {
					triangle(v_s, ws, f.n, f.t, fragmentShader, uniforms)
				} else if mode == .wireframe {
					triangleWire(v_s.map({($0.0,$0.1)}), (255,255,255))
				}
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
	/*
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
	*/
	func triangleWire(_ v: [Point2], _ color: Color){
		let csr = v.map({ (vv: Point2) -> Int in
			let xbit = (vv.0 < 0 ? 0b1: 0b0) + (vv.0 >= Scalar(width) ? 0b10: 0b0)// as Int
			let ybit = (vv.1 < 0 ? 0b100: 0b0) + (vv.1 >= Scalar(height) ? 0b1000: 0b0)// as Int
			return xbit + ybit
		})
		
		clippedLine(v[0], v[1], csr[0], csr[1], color)
		clippedLine(v[1], v[2], csr[1], csr[2], color)
		clippedLine(v[2], v[0], csr[2], csr[0], color)
		
	}
	
	func clippedLine(_ p0: Point2, _ p1: Point2, _ c0: Int, _ c1: Int, _ color: Color){
		if (c0 & c1) > 0 {
			return
			
		} else if (c0 | c1) == 0 {
			line(p0, p1, color)
			
		} else {
			// We want c0 != 0, swap if needed (we know both won't be null).
			let lc0, lc1 : Int
			let lp0, lp1 : Point2
			if c0 != 0 {
				lc0 = c0
				lc1 = c1
				lp0 = p0
				lp1 = p1
			} else {
				lc0 = c1
				lc1 = c0
				lp0 = p1
				lp1 = p0
			}
			
			let w = Scalar(width) - 1
			let h = Scalar(height) - 1
			let lp = lp0 - lp1 // lp != 0
			let nlp0 : Point2
			
			// Intersects lp0 with the side.
			if (lc0 >> 3) == 1 {
				//bottom
				let nlp0x = (lp.0 / lp.1) * (h - lp1.1) + lp1.0
				nlp0 = (floor(nlp0x),h)
				
			} else if ((lc0 >> 2) & 0b1) == 1 {
				//top
				let nlp0x = (lp.0 / lp.1) * (0 - lp1.1) + lp1.0
				nlp0 = (floor(nlp0x),0)
				
			} else if ((lc0 >> 1) & 0b1) == 1 {
				//right
				let nlp0y = (lp.1 / lp.0) * (w - lp1.0) + lp1.1
				nlp0 = (w,floor(nlp0y))
				
			} else {
				// left
				let nlp0y = (lp.1 / lp.0) * (0 - lp1.0) + lp1.1
				nlp0 = (0,floor(nlp0y))
				
			}
			// Update c0
			let xbit = (nlp0.0 < 0 ? 0b1: 0b0) + (nlp0.0 >= Scalar(width) ? 0b10: 0b0)// as Int
			let ybit = (nlp0.1 < 0 ? 0b100: 0b0) + (nlp0.1 >= Scalar(height) ? 0b1000: 0b0)// as Int
			let nlc0 = xbit + ybit
			// Draw new line
			clippedLine(nlp0, lp1, nlc0, lc1, color)
			
		}
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
