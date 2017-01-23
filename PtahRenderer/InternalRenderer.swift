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
	
	private(set) public var width = 256
	private(set) public var height = 256
	
	fileprivate var buffers: [Framebuffer]
	fileprivate var currentBuffer: Int
	var mode : RenderingMode
	var culling : CullingMode
	
	
	init(width _width: Int, height _height: Int){
		
		width = _width
		height = _height
		buffers = [Framebuffer(width: _width, height: _height)]
		currentBuffer = 0
		mode = .shaded
		culling = .backface
		
	}
	
	
	func addFramebuffer(width _width: Int, height _height: Int){
		
		buffers.append(Framebuffer(width: _width, height: _height))
		
	}
	
	
	func bindFramebuffer(i: Int){
		
		if i < buffers.count {
			currentBuffer = i
			width = buffers[currentBuffer].width
			height = buffers[currentBuffer].height
		}
		
	}
	
	
	func drawMesh(mesh: Mesh, program: Program, depthOnly: Bool = false){
		
		let halfWidth = Scalar(width)*0.5
		let halfHeight = Scalar(height)*0.5
		
		//let f = mesh.faces[1]
		for f in mesh.faces {
		
			//--- Vertex shader
			//--View space and clip space
			let v_proj = OutputFace(v0: program.vertexShader(f.v0),
			                        v1: program.vertexShader(f.v1),
			                        v2: program.vertexShader(f.v2))
		
			//--Clipping

			// Due to the way the rasterizer work, the clipping needs are limited.
			// Indeed, each triangle bounding box is clamped wtr the screen dimensions,
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
			

			// Clip half space if v_proj.3 <= 0
			if (v_proj.v0.v.3 <= 0.0 && v_proj.v1.v.3 <= 0.0 && v_proj.v2.v.3 <= 0.0) {
				continue
			}
			
			var triangles : [OutputFace] = []

			if	(v_proj.v0.v.3 > 0.0 && v_proj.v1.v.3 > 0.0 && v_proj.v2.v.3 > 0.0) &&
				(abs(v_proj.v0.v.2) < v_proj.v0.v.3 &&
				 abs(v_proj.v1.v.2) < v_proj.v1.v.3 &&
				 abs(v_proj.v2.v.2) < v_proj.v2.v.3) {
				
				
				let v_ndc = OutputFace(
					v0: OutputVertex(
						v: (v_proj.v0.v.0/v_proj.v0.v.3, v_proj.v0.v.1/v_proj.v0.v.3, v_proj.v0.v.2/v_proj.v0.v.3, v_proj.v0.v.3),
						t: v_proj.v0.t, n: v_proj.v0.n, others: v_proj.v0.others),
					v1: OutputVertex(
						v: (v_proj.v1.v.0/v_proj.v1.v.3, v_proj.v1.v.1/v_proj.v1.v.3, v_proj.v1.v.2/v_proj.v1.v.3, v_proj.v1.v.3),
						t: v_proj.v1.t, n: v_proj.v1.n, others: v_proj.v1.others),
					v2: OutputVertex(
						v: (v_proj.v2.v.0/v_proj.v2.v.3, v_proj.v2.v.1/v_proj.v2.v.3, v_proj.v2.v.2/v_proj.v2.v.3, v_proj.v2.v.3),
						t: v_proj.v2.t, n: v_proj.v2.n, others: v_proj.v2.others)
				)
				
				
				triangles = [v_ndc]
				
			} else {
				
				var vertices : [OutputVertex] = []
				clipEdge(v0: v_proj.v0, v1: v_proj.v1, vertices: &vertices)
				clipEdge(v0: v_proj.v1, v1: v_proj.v2,  vertices: &vertices)
				clipEdge(v0: v_proj.v2, v1: v_proj.v0, vertices: &vertices)
				
				if vertices.count < 3 {
					continue
				}
				
				if vertices.last! == vertices.first! {
					vertices.remove(at: vertices.count - 1)
				}
				for i in 0..<vertices.count {
					vertices[i].v = (vertices[i].v.0 / vertices[i].v.3, vertices[i].v.1/vertices[i].v.3, vertices[i].v.2/vertices[i].v.3, vertices[i].v.3)
				}
				
				for i in 1..<vertices.count-1 {
					triangles.append(OutputFace(v0: vertices[0], v1: vertices[i], v2: vertices[i+1]))
				}

			}
			
			for v_p in triangles {
				
				//--Backface culling
				//We compute it manually to avoid using a cross product and extract the 3rd component
				let orientation =  (culling == .backface) ? (v_p.v1.v.0 - v_p.v0.v.0) * (v_p.v2.v.1 - v_p.v0.v.1) - (v_p.v1.v.1 - v_p.v0.v.1) * (v_p.v2.v.0 - v_p.v0.v.0) : 1.0
				
				if orientation < 0.0 {
					continue
				}
				
				//--Screen space
				let v_s = [(floor((v_p.v0.v.0 + 1.0) * halfWidth), floor((-1.0 * v_p.v0.v.1 + 1.0) * halfHeight), v_p.v0.v.2),
						   (floor((v_p.v1.v.0 + 1.0) * halfWidth), floor((-1.0 * v_p.v1.v.1 + 1.0) * halfHeight), v_p.v1.v.2),
						   (floor((v_p.v2.v.0 + 1.0) * halfWidth), floor((-1.0 * v_p.v2.v.1 + 1.0) * halfHeight), v_p.v2.v.2)]
				
				//--- Shading
				if mode == .shaded {
					
					//triangle(v_s, ws, f.n, f.t, program)
					let (mini, maxi) = boundingBox(v_s, width, height)
					
					for x in Int(mini.0)...Int(maxi.0) {
						for y in Int(mini.1)...Int(maxi.1) {
							
							let bary = barycentre(Point3(Scalar(x), Scalar(y), 0.0), v_s[0], v_s[1], v_s[2])
							
							if (bary.0 < 0.0 || bary.1 < 0.0 || bary.2 < 0.0){ continue }
							
							var persp = (bary.0/v_p.v0.v.3, bary.1/v_p.v1.v.3, bary.2/v_p.v2.v.3)
							persp = persp / (persp.0 + persp.1 + persp.2)
							
							
							let z = (v_s[0].2 * bary.0 + v_s[1].2 * bary.1 + v_s[2].2 * bary.2)
							//Maybe need to compute the depth with the same interpolation ?
							//let z = (persp.0 * v_s[0].2 + persp.1 * v_s[1].2 + persp.2 * v_s[2].2)
							
							if (z < buffers[currentBuffer].getDepth(x, y)){
								if depthOnly {
									buffers[currentBuffer].setDepth(x, y, z)
									continue
								}
								
								let tex = barycentricInterpolation(coeffs: persp, t1: v_p.v0.t, t2: v_p.v1.t, t3: v_p.v2.t)
								let nor = barycentricInterpolation(coeffs: persp, t1: v_p.v0.n, t2: v_p.v1.n, t3: v_p.v2.n)
								let others = barycentricInterpolation(coeffs: persp, t1: v_p.v0.others, t2: v_p.v1.others, t3: v_p.v2.others)
								
								let fragmentInput = InputFragment(p: (x,y,z), n: nor, t: tex, others: others)
								
								if let color = program.fragmentShader(fragmentInput) {
									// If color is nil, the fragment is discarded.
									buffers[currentBuffer].set(x, y, color)
									buffers[currentBuffer].setDepth(x, y, z)
								}
							}
						}
					}
				} else if mode == .wireframe {
					triangleWire([(v_s[0].0,v_s[0].1), (v_s[1].0,v_s[1].1), (v_s[2].0,v_s[2].1)], (255,255,255))
				}
			}
		}
		
	}
	
	
	private func clipEdge(v0: OutputVertex, v1: OutputVertex, vertices: inout [OutputVertex]){
		
		var v0n : OutputVertex
		var v1n : OutputVertex
		let v0Inside = v0.v.3 > 0.0 && v0.v.2 > -v0.v.3// && v0.v.2 < v0.v.3
		let v1Inside = v1.v.3 > 0.0 && v1.v.2 > -v1.v.3// && v0.v.2 < v0.v.3
		
		if v0Inside && v1Inside {
			// Great, nothing to do
			v0n = v0
			v1n = v1
		} else if v0Inside {
			v0n = v0
			let d1 = v1.v.2 + v1.v.3
			let d0 = v0.v.2 + v0.v.3
			v1n = clipPoint(vIn: v0, vOut: v1, dIn: d0, dOut: d1)

		} else if v1Inside {
			let d1 = v1.v.2 + v1.v.3
			let d0 = v0.v.2 + v0.v.3
			v0n = clipPoint(vIn: v1, vOut: v0, dIn: d1, dOut: d0)
			v1n = v1
		} else {
			// Both are outside, on the same side. Remove the edge.
			return
		}
		
		if(vertices.count == 0 || vertices.last! != v0n){
			vertices.append(v0n)
		}
		vertices.append(v1n)
		
	}
	
	
	func clipPoint(vIn v0: OutputVertex, vOut v1: OutputVertex, dIn d0 : Scalar, dOut d1 : Scalar) -> OutputVertex {
		
		let factor = 1.0 / (d1 - d0)
		var newOthers : [Scalar] = []
		
		for i in 0..<v0.others.count {
			newOthers.append(factor * (d1 * v0.others[i] - d0 * v1.others[i]))
		}
		
		return OutputVertex(v: factor*(d1 * v0.v - d0 * v1.v),
		                   t: factor*(d1 * v0.t - d0 * v1.t),
		                   n: factor*(d1 * v0.n - d0 * v1.n),
		                   others: newOthers)
		
	}
	
	
	private func triangleWire(_ v: [Point2], _ color: Color){
		
		let csr0 = (v[0].0 < 0 ? 0b1: 0b0) + (v[0].0 >= Scalar(width) ? 0b10: 0b0)
				 + (v[0].1 < 0 ? 0b100: 0b0) + (v[0].1 >= Scalar(height) ? 0b1000: 0b0)
		
		let csr1 = (v[1].0 < 0 ? 0b1: 0b0) + (v[1].0 >= Scalar(width) ? 0b10: 0b0)
				 + (v[1].1 < 0 ? 0b100: 0b0) + (v[1].1 >= Scalar(height) ? 0b1000: 0b0)
		
		let csr2 = (v[2].0 < 0 ? 0b1: 0b0) + (v[2].0 >= Scalar(width) ? 0b10: 0b0)
				 + (v[2].1 < 0 ? 0b100: 0b0) + (v[2].1 >= Scalar(height) ? 0b1000: 0b0)

		clippedLine(v[0], v[1], csr0, csr1, color)
		clippedLine(v[1], v[2], csr1, csr2, color)
		clippedLine(v[2], v[0], csr2, csr0, color)
		
	}
	
	
	private func clippedLine(_ p0: Point2, _ p1: Point2, _ c0: Int, _ c1: Int, _ color: Color){
		
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
			let xbit = (nlp0.0 < 0 ? 0b1: 0b0) + (nlp0.0 >= Scalar(width) ? 0b10: 0b0)
			let ybit = (nlp0.1 < 0 ? 0b100: 0b0) + (nlp0.1 >= Scalar(height) ? 0b1000: 0b0)
			let nlc0 = xbit + ybit
			
			// Draw new line
			clippedLine(nlp0, lp1, nlc0, lc1, color)
		}
		
	}

	
	private func line(_ a_: Point2, _ b_: Point2, _ color: Color){
		
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
		var error : Scalar = 0.0
		
		var y = Int(a.1)
		for x in Int(a.0)...Int(b.0) {
			steep ? buffers[currentBuffer].set(y, x, color): buffers[currentBuffer].set(x, y, color)
			error += differror
			if(error > 0.5){
				y += shift
				error -= 1.0
			}
		}
		
	}
	
	
	func clear(color: Bool = true, depth: Bool = true){
		
		if(color){
			buffers[currentBuffer].clearColor((0, 0, 0))
		}
		if(depth){
			buffers[currentBuffer].clearDepth()
		}
		
	}
	
	
	func flushBuffer() -> [Pixel] {
		
		return buffers[currentBuffer].pixels
		
	}
	
	
	func flushDepthBuffer() -> [Scalar] {
		
		return buffers[currentBuffer].zbuffer
		
	}
	
	
	//MARK: OSX dependant
	
#if os(OSX)
	
	func flushImage() -> NSImage {
		
		let image = buffers[currentBuffer].imageFromRGBA32Bitmap()
		return image
		
	}
	
#endif
	
}
