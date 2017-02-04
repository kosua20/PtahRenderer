//
//  TGALoader.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 08/03/2016.
//  Copyright © 2016 Simon Rodriguez. All rights reserved.
//

import Foundation

/*
	pixelDepth:
		- 24: BGR
		- 32: BGRA
		- 8: B

	imageType:
		- 0: Issue
		- 1: Color map
		- 2: Uncompressed, true-color
		- 3: B&W
*/

public final class TGALoader {
	
	
	public static func writeTGA(pixels: [Pixel], width: Int, height: Int, path: String){
		
		let data = NSMutableData()
		
		var header = [UInt8](repeating: 0, count: 18)
		header[2]  = 2
		header[8]  = 0
		header[9]  = 0
		header[10] = 0
		header[11] = 0
		header[12] = UInt8(width % 256)
		header[13] = UInt8(width / 256)
		header[14] = UInt8(height % 256)
		header[15] = UInt8(height / 256)
		header[16] = 24; // bits per pixel
		header[17] = 0; // image descriptor:
		data.append(header, length: 18)
		let imageLength = width*height*3
		let pixeldata = pixels.flatMap({[$0.b, $0.g, $0.r]})
		data.append(pixeldata, length: imageLength)
		let _ = data.write(toFile: path.hasSuffix(".tga") ? path: (path + ".tga") , atomically: true)
		
	}
	
	
	public static func loadTGA(path: String) -> (Int, Int, [Pixel]){
		
		guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
			assertionFailure("Couldn't load the tga")
			return (0, 0, [])
		}
		var header: [UInt8] = [UInt8](repeating: 0, count: 18)
		data.copyBytes(to: &header, from:Range(uncheckedBounds: (lower: 0, upper: 18)))
		
		let useColorMap = header[1] != 0
		
		let imageType = Int(header[2])
		if useColorMap || ([0, 1, 3].contains(imageType)) {
			assertionFailure("Not a color TGA")
			return (0, 0, [])
		}
		
		let IDLength = header[0]
		let width = Int(header[13])*256 + Int(header[12])
		let height = Int(header[15])*256 + Int(header[14])
		let pixelDepth = header[16]
		
		let lengthImage = Int(pixelDepth) * width * height / 8
		let range =  Range(uncheckedBounds: (lower: 18+Int(IDLength), upper: 18+Int(IDLength)+lengthImage))
		var content: [UInt8] = [UInt8](repeating: 0, count: lengthImage)
		data.copyBytes(to: &content, from: range)
		var pixels: [Pixel]
		if pixelDepth == 8 {
			pixels = content.map({Pixel($0, $0, $0)})
		} else {
			pixels = [Pixel](repeating: Pixel(0), count: width * height)
			if pixelDepth == 24 {
				for i in 0..<(width * height){
					pixels[i].r = content[3*i+2]
					pixels[i].g = content[3*i+1]
					pixels[i].b = content[3*i]
				}
			} else if pixelDepth == 32 {
				for i in 0..<(width * height){
					pixels[i].r = content[4*i+2]
					pixels[i].g = content[4*i+1]
					pixels[i].b = content[4*i]
					pixels[i].a = content[4*i+3]
				}
			}

		}
		return (width, height, pixels)
		
	}
	
}
