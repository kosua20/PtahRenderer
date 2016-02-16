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
		
		tex = Texture(path: "/Users/simon/Desktop/balloon.png")
		tex.flipVertically()
		mesh = Model(path: "/Users/simon/Desktop/balloon.obj")
		mesh.center()
		mesh.normalize()
		mesh.expand()
	}
	private var tex : Texture
	private var mesh : Model
	private var time = 0.0
	func render(){
		
		
		
		
		
		drawMesh(mesh,texture: tex)
		let theta = time/10.0
		cam_pos = normalized((cos(theta),0.0,sin(theta)))
				time+=1.0
	}
	
	private var l = normalized((1.0,0.0,-1.0))
	private var cam_pos = normalized((10.0,0.0,10.0))
	
	
	
	
	func drawMesh(mesh : Model, texture : Texture? = nil){
		let view = Matrix4.lookAtMatrix(cam_pos, target: (0.0,0.0,0.0), up: (0.0,1.0,0.0))
		//var proj = Matrix4.perspectiveMatrix(fov:75.0, aspect: Scalar(width)/Scalar(height), near: 0.01, far: 100.0)*view
		let halfWidth = Scalar(width)*0.5
		let halfHeight = Scalar(height)*0.5
		for f in mesh.faces {
			
		
			let vp = f.v.map({view*($0.0,$0.1,$0.2,1.0)})
			/*if vp.filter({abs($0.0) > 1.0 || abs($0.1) > 1.0}).count > 0 {
				continue
			}*/
			let v_s = vp.map({ (floor(($0.0+1.0)*halfWidth),floor(($0.1+1.0)*halfHeight))})
			triangleWire(v_s,(255,255,255))
			//triangle(v_s,f.n, f.t,texture!)
			
			//Face normal for backface culling
			
			/*
			let v_w = f.v
			var n = cross(v_w[2] - v_w[0],v_w[1] - v_w[0])
			normalize(&n)
			let cosFactor = dot(n,cam_pos)
			if cosFactor >= 0.0 {*/
			//	triangle(v_s,f.n, f.t,texture!)
			//}
		}
	}
	
	func triangle(v : [Vertex], _ n : [Normal], _ uv : [UV],_ texture : Texture){
		let (mini, maxi) = boundingBox(v,width,height)
		for x in Int(mini.0)...Int(maxi.0) {
			for y in Int(mini.1)...Int(maxi.1) {
				let bary = barycentre(Point3(Scalar(x),Scalar(y),0.0),v[0],v[1],v[2])
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
	
	func triangleWire(v : [Point2],_ color : Color){
			line(v[0], v[1], color)
			line(v[1], v[2], color)
			line(v[2], v[0], color)
	}

	
	func line(a_ : Point2,_ b_ : Point2,_ color : Color){
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
		let diffx = b.0 - a.0
		let diffy = b.1 - a.1
		let shift = b.1 > a.1 ? 1 : -1
		
		//Error
		let differror = abs(diffy/diffx)
		var error = 0.0
		
		var y = Int(a.1)
		for x in Int(a.0)...Int(b.0) {
			steep ? buffer.set(y,x,color) : buffer.set(x,y,color)
			error += differror
			if(error > 0.5){
				y += shift
				error -= 1.0
			}
		}
	}
	
	func clear(color : Bool = true, depth: Bool = true){
		if(color){
			buffer.clearColor((0,0,0))
		}
		if(depth){
			buffer.clearDepth()
		}
	}
	
	func renderImage() -> NSImage {
		
		var startTime = CFAbsoluteTimeGetCurrent();
		render()
		print("[Render]: \t" + String(format: "%.4fs", CFAbsoluteTimeGetCurrent() - startTime))

		
		startTime = CFAbsoluteTimeGetCurrent();
		buffer.flipVertically()
		let image = buffer.imageFromRGBA32Bitmap()
		print("[Backing]: \t" + String(format: "%.4fs", CFAbsoluteTimeGetCurrent() - startTime))
		return image
	}
	
}
