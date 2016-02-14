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
	
	func render() -> [Pixel]{
		//let tex = Texture(path: "/Users/simon/Desktop/test.png")
		/*let mesh = Model(path: "/Users/simon/Desktop/balloon.obj")
		mesh.center()
		mesh.normalize()*/
		
		
		pixels = [Pixel](count: width*height, repeatedValue: Pixel(0))
		
		var startTime = CFAbsoluteTimeGetCurrent();
		
		triangle((10,70), (50,160), (70,80), (255,0,0))
		triangle((180,50), (150,1), (70,180), (255,255,255))
		triangle((180,150), (120,160), (130,180), (0,255,0))
		
		print("[Internal]: " + String(format: "%.4fs", CFAbsoluteTimeGetCurrent() - startTime))
		return pixels
	}
	
	func triangle(v0 : Point2i,_ v1 : Point2i,_ v2 : Point2i,_ color : Color){
		line(v0,v1,color)
		line(v1,v2,color)
		line(v2,v0,color)
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
	func drawMesh(mesh : Model){
		let halfWidth = Scalar(width)*0.5
		let halfHeight = Scalar(height)*0.5
		for f in mesh.faces {
			let v0 = mesh.vertices[f.0.v]
			let v1 = mesh.vertices[f.1.v]
			let v2 = mesh.vertices[f.2.v]
			let v0_ = (Int((v0.0+1.0)*halfWidth),Int((v0.1+1.0)*halfHeight))
			let v1_ = (Int((v1.0+1.0)*halfWidth),Int((v1.1+1.0)*halfHeight))
			let v2_ = (Int((v2.0+1.0)*halfWidth),Int((v2.1+1.0)*halfHeight))
			triangle(v0_,v1_,v2_,(128,255,172))
		}
	}
	
	
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
