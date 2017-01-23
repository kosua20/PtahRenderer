//
//  Texture.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 13/02/2016.
//  Copyright © 2016 Simon Rodriguez. All rights reserved.
//

import Foundation

enum TextureMode {
	case clamp
	case wrap
	case unsafe
}

enum FilteringMode {
	case nearest
	case linear
}

final class Texture {
	
	let width: Int
	let height: Int
	let components: Int
	var pixels: [Pixel]
	var mode: TextureMode = .clamp
	var filtering: FilteringMode = .nearest
	
	init(path: String){
		
		if path.hasSuffix(".png"){
			
		#if os(Linux)
			assert(false, "On Linux, only TGA can be currently loaded.")
		#else
			
			let dataProvider = CGDataProvider(filename: path)
			assert(dataProvider != nil)
			let image = CGImage(pngDataProviderSource: dataProvider!,
			                    decode: nil,
			                    shouldInterpolate: false,
			                    intent: .defaultIntent)
			
			if let imageData = image?.dataProvider?.data {
				width = (image?.width)!
				height = (image?.height)!
				components = (image?.bitsPerPixel)! / 8
				let data = imageData as Data
				if components == 4 {
					pixels = Array(UnsafeBufferPointer(start: (data as NSData).bytes.bindMemory(to: Pixel.self, capacity: data.count), count: data.count/4))
				} else {
					let temp_pixels = Array(UnsafeBufferPointer(start: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count), count: data.count))
					
					pixels = [Pixel](repeating: Pixel(0), count: temp_pixels.count / components)
					switch components {
					case 3:
						for i in 0..<(temp_pixels.count / components){
							pixels[i] = Pixel(temp_pixels[3*i], temp_pixels[3*i+1], temp_pixels[3*i+2])
						}
					case 2:
						for i in 0..<(temp_pixels.count / components){
							pixels[i] = Pixel(temp_pixels[2*i], temp_pixels[2*i+1], 0)
						}
					case 1:
						for i in 0..<(temp_pixels.count){
							pixels[i] = Pixel(temp_pixels[i])
						}
					default:
						pixels = []
					}
					
				}
				
				flipVertically()
				return
			}
			
		#endif
			
		} else if path.hasSuffix(".tga"){
			let (w, h, p) = TGALoader.loadTGA(path: path)
			width = w
			height = h
			components = 3
			pixels = p
			flipVertically()
			return
		} else {
			assert(false, "Only .png and .tga can currently be loaded.")
		}
		
		width = 0
		height = 0
		components = 0
		pixels = []
		
	}
	
	
	private subscript(a: Int, b: Int) -> Pixel {
		
		if mode == .clamp {
			return pixels[clamp(b, 0, height-1) * width + clamp(a, 0, width-1)]
		} else if mode == .wrap {
			let nb = b%height
			let na = a%width
			return pixels[(nb < 0 ? nb + height : nb) * width + (na < 0 ? na + width : na)]
		}
		return pixels[b*width+a]
	}
	
	subscript(u: Scalar, v: Scalar ) -> Pixel {
		
		let a = u*Scalar(width)
		let b = v*Scalar(height)
		
		if filtering == .linear {
			
			let a0 = Int(floor(a))
			let b0 = Int(floor(b))
			let a1 = a0+1
			let b1 = b0+1
			let afrac = a - Scalar(a0)
			let bfrac = b - Scalar(b0)
			
			let c00 = self[a0, b0]
			let c01 = self[a0, b1]
			let c10 = self[a1, b0]
			let c11 = self[a1, b1]
			
			let d0 = ((1.0 - bfrac) * c00 + bfrac * c01)
			let d1 = ((1.0 - bfrac) * c10 + bfrac * c11)
			
			return (1.0 - afrac) * d0 + afrac * d1
		}
		
		return self[Int(a), Int(b)]
		
	}
	
	
	private func flipVertically(){
		let half = height >> 1
		for y in 0..<half {
			swap(&(pixels[y*width..<(y+1)*width]), &(pixels[width*(height-y-1)..<width*(height-y)]))
		}
	}
	
	/*subscript(uv: Point2) -> Pixel {
		return self[uv.0 as Scalar, uv.1 as Scalar]
	}*/

}

final class ScalarTexture {
	
	let width: Int
	let height: Int
	var values: [Scalar]
	var mode: TextureMode = .clamp
	var filtering: FilteringMode = .nearest
	
	init(buffer: [Scalar], width _width: Int, height _height: Int){
		width = _width
		height = _height
		values = buffer
	}
	
	
	private subscript(a: Int, b: Int) -> Scalar {
		
		if mode == .clamp {
			return values[clamp(b, 0, height-1) * width + clamp(a, 0, width-1)]
		} else if mode == .wrap {
			let nb = b%height
			let na = a%width
			return values[(nb < 0 ? nb + height : nb) * width + (na < 0 ? na + width : na)]
		}
		return values[b*width+a]
	}
	
	subscript(u: Scalar, v: Scalar ) -> Scalar {
		
		let a = u*Scalar(width)
		let b = v*Scalar(height)
		
		if filtering == .linear {
			
			let a0 = Int(floor(a))
			let b0 = Int(floor(b))
			let a1 = a0+1
			let b1 = b0+1
			let afrac = a - Scalar(a0)
			let bfrac = b - Scalar(b0)
			
			let c00 = self[a0, b0]
			let c01 = self[a0, b1]
			let c10 = self[a1, b0]
			let c11 = self[a1, b1]
			
			let d0 = ((1.0 - bfrac) * c00 + bfrac * c01)
			let d1 = ((1.0 - bfrac) * c10 + bfrac * c11)
			
			return (1.0 - afrac) * d0 + afrac * d1
		}
		
		return self[Int(a), Int(b)]
		
	}
	
	
	private func flipVertically(){
		let half = height >> 1
		for y in 0..<half {
			swap(&(values[y*width..<(y+1)*width]), &(values[width*(height-y-1)..<width*(height-y)]))
		}
	}
	
	
}

