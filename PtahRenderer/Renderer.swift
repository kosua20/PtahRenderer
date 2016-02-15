//
//  Renderer.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 13/02/2016.
//  Copyright © 2016 Simon Rodriguez. All rights reserved.
//

import Foundation
import Cocoa

class Renderer {
	private var width = 512
	private var height = 512
	
	private var buffer : Framebuffer

	init(width _width : Int,height _height : Int){
		width = _width
		height = _height
		buffer = Framebuffer(width: width, height: height)
	}
	
	func render(){
		let tex = Texture(path: "/Users/simon/Desktop/balloon.png")
		tex.flipVertically()
		let mesh = Model(path: "/Users/simon/Desktop/balloon.obj")
		mesh.center()
		mesh.normalize()
		mesh.expand()
		
		
		let startTime = CFAbsoluteTimeGetCurrent();
		
		drawMesh(mesh,texture: tex)
		
		print("[Internal]: " + String(format: "%.4fs", CFAbsoluteTimeGetCurrent() - startTime))
	
	}
	
	private var l = normalized((1.0,0.0,-1.0))
	private var cam_pos = normalized((0.0,0.0,-1.0))
	
	
	func drawMesh(mesh : Model, texture : Texture? = nil){
		let halfWidth = Scalar(width)*0.5
		let halfHeight = Scalar(height)*0.5
		for f in mesh.faces {
			
			let v_s =  f.v.map({ (floor(($0.0+1.0)*halfWidth),floor(($0.1+1.0)*halfHeight),$0.2)})
			let v_w = f.v
			var n = cross(v_w[2] - v_w[0],v_w[1] - v_w[0])
			normalize(&n)
			let cosFactor = dot(n,cam_pos)
			if cosFactor >= 0.0 {
				triangle(v_s,f.n, f.t,texture!)
			}
		}
	}
	
	func triangle(v : [Vertex], _ n : [Normal], _ uv : [UV],_ texture : Texture){
		let (mini, maxi) = boundingBox(v,width,height)
		for x in Int(mini.0)...Int(maxi.0) {
			for y in Int(mini.1)...Int(maxi.1) {
				let bary = barycentre(Point3f(Scalar(x),Scalar(y),0.0),v[0],v[1],v[2])
				if (bary.0 < 0.0 || bary.1 < 0.0 || bary.2 < 0.0){ continue }
				let z =  v[0].2 * bary.0 + v[1].2 * bary.1 + v[2].2 * bary.2
				if (buffer.zbuffer[y*width + x] < z){
					buffer.zbuffer[y*width + x] = z
					let tex = barycentricInterpolation(bary, t1: uv[0], t2: uv[1], t3: uv[2])
					let nor = normalized(barycentricInterpolation(bary, t1: n[0], t2: n[1], t3: n[2]))
					let cosfactor = max(0.0,dot(-1.0*nor,l))
					buffer.set(x, y, cosfactor*texture[tex.0,tex.1].rgb)
				}
			}
		}
	}
	
	func line(a_ : Point2i,_ b_ : Point2i,_ color : Color){
		var steep = false
		var a = a_
		var b = b_
		
		//Switch orientation if steep line
		if(abs(a.0 - b.0) < abs(a.1 - b.1)){
			steep = true
			swap(&(a.0),&(a.1))
			swap(&(b.0),&(b.1))
		}
		
		//Order points along x axis
		if(a.0 > b.0){
			swap(&a, &b)
		}
		
		//Precompute
		let diffx = Scalar(b.0 - a.0)
		let diffy = Scalar(b.1 - a.1)
		let shift = b.1 > a.1 ? 1 : -1
		
		//Error
		let differror = abs(diffy/diffx)
		var error = 0.0
		
		var y = a.1
		for x in a.0...b.0 {
			steep ? buffer.set(y,x,color) : buffer.set(x,y,color)
			error += differror
			if(error > 0.5){
				y += shift
				error -= 1.0
			}
		}
	}
	
	
	func renderImage() -> NSImage {
		
		var startTime = CFAbsoluteTimeGetCurrent();
		render()
		print("[Rendering]: " + String(format: "%.4fs", CFAbsoluteTimeGetCurrent() - startTime))
		
		startTime = CFAbsoluteTimeGetCurrent();
		buffer.swapPixelBuffer()
		let image = buffer.imageFromRGBA32Bitmap()
		print("[Backing]: " + String(format: "%.4fs", CFAbsoluteTimeGetCurrent() - startTime))
		buffer.dumpZbuffer()
		return image
	}
	
}
