//
//  Texture.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 13/02/2016.
//  Copyright © 2016 Simon Rodriguez. All rights reserved.
//

import Foundation

class Texture {
	let width : Int
	let height : Int
	let components : Int
	var pixels : [Pixel]
	var mode : TextureMode = .Wrap
	
	
	
	
	init(path : String){
		
		if path.hasSuffix(".png"){
			
		#if os(Linux)
			assert(false,"On Linux, only TGA can be currently loaded.")
		#else
			let dataProvider = CGDataProviderCreateWithFilename(path)
			assert(dataProvider != nil)
			let image = CGImageCreateWithPNGDataProvider(dataProvider!, nil, false, .RenderingIntentDefault)
			if let imageData = CGDataProviderCopyData(CGImageGetDataProvider(image)) {
				width = CGImageGetWidth(image)
				height = CGImageGetHeight(image)
				components = CGImageGetBitsPerPixel(image) / 8
				let data = imageData as NSData
				if components == 4 {
					pixels = Array(UnsafeBufferPointer(start: UnsafePointer<Pixel>(data.bytes), count: data.length/4))
				} else {
					let temp_pixels = Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>(data.bytes), count: data.length))
					
					pixels = [Pixel](count: temp_pixels.count / components, repeatedValue: Pixel(0))
					switch components {
					case 3:
						for i in 0..<(temp_pixels.count / components){
							pixels[i] = Pixel(temp_pixels[3*i],temp_pixels[3*i+1],temp_pixels[3*i+2])
						}
					case 2:
						for i in 0..<(temp_pixels.count / components){
							pixels[i] = Pixel(temp_pixels[2*i],temp_pixels[2*i+1],0)
						}
					case 1:
						for i in 0..<(temp_pixels.count){
							pixels[i] = Pixel(temp_pixels[i])
						}
					default:
						pixels = []
					}
					
				}
				return
			}
		#endif
		} else if path.hasSuffix(".tga"){
			let (w,h,p) = TGALoader.loadTGA(path)
			width = w
			height = h
			components = 3
			pixels = p
			return
		} else {
			assert(false,"Only .png and .tga can currently be loaded.")
		}
		width = 0
		height = 0
		components = 0
		pixels = []
		
		
	}
	
	//Nearest neighbours
	subscript(a : Int, b : Int) -> Pixel {
		//assert(a < width && a >= 0 && b < height && b >= 0, "Index error in texture")
		if mode == .Clamp {
			return pixels[min(height-1,max(0,b)) * width + min(width-1,max(0,a))]
		}
		if mode == .Wrap {
			return pixels[(b%height) * width + (a%width)]
		}
		return pixels[b*width+a]
	}
	
	subscript(u : Scalar, v : Scalar) -> Pixel {
		let a = Int(u*Scalar(width))
		let b = Int(v*Scalar(height))
		return self[a,b]
	}
	
	
	func flipVertically(){
		let half = height >> 1
		for y in 0..<half {
			swap(&(pixels[y*width..<(y+1)*width]),&(pixels[width*(height-y-1)..<width*(height-y)]))
		}
	}
	/*subscript(uv : Point2) -> Pixel {
		return self[uv.0 as Scalar, uv.1 as Scalar]
	}*/
	
	
	
}