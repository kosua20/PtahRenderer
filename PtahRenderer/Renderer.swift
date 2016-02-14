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
	
	private var pixels : [Pixel] = []
	private var zbuffer : [Scalar] = []
	
	init(width _width : Int,height _height : Int){
		width = _width
		height = _height
		pixels = [Pixel](count: width*height, repeatedValue: Pixel(0))
		zbuffer = [Scalar](count: width*height, repeatedValue: -Scalar.infinity)
	}
	
	func render() -> [Pixel]{
		//let tex = Texture(path: "/Users/simon/Desktop/test.png")
		let mesh = Model(path: "/Users/simon/Desktop/head.obj")
		mesh.center()
		mesh.normalize()
		mesh.expand()
		
		
		let startTime = CFAbsoluteTimeGetCurrent();
		
		drawMesh(mesh)
		
		print("[Internal]: " + String(format: "%.4fs", CFAbsoluteTimeGetCurrent() - startTime))
		return pixels
	}
	
	private var l = (0.0,0.0,-1.0)
	
	
	func drawMesh(mesh : Model){
		let halfWidth = Scalar(width)*0.5
		let halfHeight = Scalar(height)*0.5
		for f in mesh.faces {
			
			let v0_s = (floor((f.v[0].0+1.0)*halfWidth),floor((f.v[0].1+1.0)*halfHeight),0.0)
			let v1_s = (floor((f.v[1].0+1.0)*halfWidth),floor((f.v[1].1+1.0)*halfHeight),0.0)
			let v2_s = (floor((f.v[2].0+1.0)*halfWidth),floor((f.v[2].1+1.0)*halfHeight),0.0)
			let v0_w = f.v[0]
			let v1_w = f.v[1]
			let v2_w = f.v[2]
			var n = cross(v2_w - v0_w, v1_w - v0_w)
			normalize(&n)
			let cosFactor = dot(n,l)
			if cosFactor > 0.0 {
				triangle([v0_s,v1_s,v2_s], f.t,(UInt8(cosFactor*255),UInt8(cosFactor*255),UInt8(cosFactor*255)))
			}
		}
	}
	
	
	
	func barycentre(p : Point3f,_ v0 : Point3f,_ v1 : Point3f,_ v2 : Point3f) -> Point3f{
		let ab = v1 - v0
		let ac = v2 - v0
		let pa = v0 - p
		let uv1 = cross((ac.0,ab.0,pa.0),(ac.1,ab.1,pa.1))
		if abs(uv1.2) < 1.0 {
			return (-1,-1,-1)
		}
		return (1.0-(uv1.0+uv1.1)/uv1.2,uv1.1/uv1.2,uv1.0/uv1.2)
	}
	
	func boundingBox(vs : [Point3f]) -> (Point2f, Point2f){
		var mini  = (Scalar.infinity,Scalar.infinity)
		var maxi = (-Scalar.infinity,-Scalar.infinity)
		let lim = (Scalar(width-1),Scalar(height-1))
		//Why write a loop when you can unwind by hand
		for v in vs {
		mini.0 = max(min(mini.0,v.0),0)
		mini.1 = max(min(mini.1,v.1),0)
		maxi.0 = min(max(maxi.0,v.0),lim.0)
		maxi.1 = min(max(maxi.1,v.1),lim.1)
		}
		
		return (mini,maxi)
	}
	
	
	
	func triangle(v : [Point3f],_ uv : [Point2f],_ color : Color){
		
		let (mini, maxi) = boundingBox(v)
		for x in Int(mini.0)...Int(maxi.0) {
			for y in Int(mini.1)...Int(maxi.1) {
				let bary = barycentre(Point3f(Scalar(x),Scalar(y),0.0),v[0],v[1],v[2])
				if (bary.0 < 0.0 || bary.1 < 0.0 || bary.2 < 0.0){ continue }
				let z = v[0].2 * bary.0 + v[1].2 * bary.1 + v[2].2 * bary.2
				if (zbuffer[y*width + x] < z){
					zbuffer[y*width + x] = z
					set(x, y, color)
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
			steep ? set(y,x,color) : set(x,y,color)
			error += differror
			if(error > 0.5){
				y += shift
				error -= 1.0
			}
			
		}
	}
	
	func set(x : Int,_ y : Int,_ color : Color){
		if(x < width && y < height && x >= 0 && y >= 0){
			pixels[y * width + x].rgb = color
		}
	}
	
	func set(x : Int,_ y : Int,_ color : Pixel){
		if(x < width && y < height && x >= 0 && y >= 0){
			pixels[y * width + x] = color
		}
	}
	
	func swapPixelBuffer(){
		let half = height >> 1
		for y in 0..<half {
			swap(&(pixels[y*width..<(y+1)*width]),&(pixels[width*(height-y-1)..<width*(height-y)]))
		}
	}
	
	func renderImage() -> NSImage {
		
		var startTime = CFAbsoluteTimeGetCurrent();
		render()
		print("[Rendering]: " + String(format: "%.4fs", CFAbsoluteTimeGetCurrent() - startTime))
		
		startTime = CFAbsoluteTimeGetCurrent();
		swapPixelBuffer()
		let image = imageFromRGBA32Bitmap(pixels, width, height)
		print("[Backing]: " + String(format: "%.4fs", CFAbsoluteTimeGetCurrent() - startTime))
		
		return image
	}
	
	
	/*--Temp zone-------------*/
	
	
	
	/*--Utilities----------------------------------------------*/
	/*Courtesy of Simon Gladman, http://flexmonkey.blogspot.fr */
	/*---------------------------------------------------------*/
	
	private let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
	private let bitmapInfo:CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
	
	private func imageFromRGBA32Bitmap(pixels:[Pixel],_ width:Int,_ height:Int) -> NSImage {
		let bitsPerComponent:Int = 8
		let bitsPerPixel:Int = 32
		assert(pixels.count == Int(width * height))
		var data = pixels // Copy to mutable []
		let providerRef = CGDataProviderCreateWithCFData(NSData(bytes: &data, length: data.count * sizeof(Pixel)))
		
		
		let cgim = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, width * Int(sizeof(Pixel)), rgbColorSpace, bitmapInfo, providerRef, nil, true, .RenderingIntentDefault)
		return NSImage(CGImage: cgim!, size: NSSize(width: width, height: height))

	}
}
