//
//  Framebuffer.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 14/02/2016.
//  Copyright © 2016 Simon Rodriguez. All rights reserved.
//

import Foundation
#if os(OSX)
import Cocoa
#endif

class Framebuffer {
	internal var pixels : [Pixel] = []
	internal var zbuffer : [Scalar] = []
	fileprivate var width : Int = 512
	fileprivate var height : Int = 512
	
	init(width _width : Int,height _height : Int){
		pixels = [Pixel](repeating: Pixel(0), count: width*height)
		zbuffer = [Scalar](repeating: -Scalar.infinity, count: width*height)
	}
	
	func set(_ x : Int,_ y : Int,_ color : Color){
		if(x < width && y < height && x >= 0 && y >= 0){
			pixels[y * width + x].rgb = color
		}
	}
	
	func set(_ x : Int,_ y : Int,_ color : Pixel){
		if(x < width && y < height && x >= 0 && y >= 0){
			pixels[y * width + x] = color
		}
	}
	
	func getDepth(_ x : Int, _ y : Int) -> Scalar {
		if(x < width && y < height && x >= 0 && y >= 0){
			return zbuffer[y * width + x]
		}
		return Scalar.infinity
	}
	
	func setDepth(_ x : Int,_ y : Int,_ depth : Scalar){
		//if(x < width && y < height && x >= 0 && y >= 0){
			zbuffer[y * width + x] = depth
		//}
	}
	
	func flipVertically(){
		let half = height >> 1
		for y in 0..<half {
			swap(&(pixels[y*width..<(y+1)*width]),&(pixels[width*(height-y-1)..<width*(height-y)]))
		}
	}
	
	func clearColor(_ col : Color){
		for i in 0..<width*height {
			pixels[i].rgb = col
		}
	}
	
	func clearDepth(){
		for i in 0..<width*height {
			zbuffer[i] = -Scalar.infinity
		}
	}
	
	/*--Utilities----------------------------------------------*/
	/*Courtesy of Simon Gladman, http://flexmonkey.blogspot.fr */
	/*---------------------------------------------------------*/
	
	#if os(OSX)
	
	fileprivate let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
	fileprivate let bitmapInfo:CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
	
	internal func imageFromRGBA32Bitmap() -> NSImage {
		let bitsPerComponent:Int = 8
		let bitsPerPixel:Int = 32
		assert(pixels.count == width * height)
		let data = pixels // Copy to mutable []
		//let dda = Data(bytes: UnsafePointer<UInt8>(&data), count: data.count * sizeof(Pixel))
		let callback: CGDataProviderReleaseDataCallback = { (info: UnsafeMutableRawPointer?, data: UnsafeRawPointer, size: Int) -> () in
			return
		}
		guard let providerRef = CGDataProvider(dataInfo: nil, data: data , size: data.count * MemoryLayout<Pixel>.size, releaseData: callback) else {
				return NSImage()
		}
		
		let cgim = CGImage(width: width, height: height, bitsPerComponent: bitsPerComponent, bitsPerPixel: bitsPerPixel, bytesPerRow: width * Int(MemoryLayout<Pixel>.size), space: rgbColorSpace, bitmapInfo: bitmapInfo, provider: providerRef, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
		return NSImage(cgImage: cgim!, size: NSSize(width: width, height: height))
	}
	
	#endif
	
	internal func dumpZbuffer(){
		print("Not yet implemented.")
	}
}
