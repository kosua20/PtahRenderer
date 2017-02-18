
import Foundation


class Texture {
	
	private let width: Int
	private let height: Int
	private var pixels: [Color]
	
	
	init(named name: String){
		let path = "Resources/" + name + ".tga"
		
		guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
			assertionFailure("Couldn't load the tga")
			width = 0
			height = 0
			pixels = []
			return
		}
		
		var header: [UInt8] = [UInt8](repeating: 0, count: 18)
		data.copyBytes(to: &header, from:Range(uncheckedBounds: (lower: 0, upper: 18)))
		
		let useColorMap = header[1] != 0
		let imageType = Int(header[2])
		if useColorMap || ([0, 1, 3].contains(imageType)) {
			assertionFailure("Not a color TGA")
			width = 0
			height = 0
			pixels = []
			return
		}
		
		let IDLength = header[0]
		width = Int(header[13])*256 + Int(header[12])
		height = Int(header[15])*256 + Int(header[14])
		let pixelDepth = header[16]
	
		let lengthImage = Int(pixelDepth) * width * height / 8
		let range =  Range(uncheckedBounds: (lower: 18+Int(IDLength), upper: 18+Int(IDLength)+lengthImage))
		var content: [UInt8] = [UInt8](repeating: 0, count: lengthImage)
		data.copyBytes(to: &content, from: range)
		
		if pixelDepth == 8 {
			pixels = content.map({Color(Scalar($0)/255.0, Scalar($0)/255.0, Scalar($0)/255.0)})
		} else {
			pixels = [Color](repeating: Color(0.0,0.0,0.0), count: width * height)
			if pixelDepth == 24 {
				for i in 0..<(width * height){
					let r = Scalar(content[3*i+2])/255.0
					let g = Scalar(content[3*i+1])/255.0
					let b = Scalar(content[3*i])/255.0
					pixels[i] = Color(r,g,b)
				}
			} else if pixelDepth == 32 {
				for i in 0..<(width * height){
					let r = Scalar(content[4*i+2])/255.0
					let g = Scalar(content[4*i+1])/255.0
					let b = Scalar(content[4*i])/255.0
					pixels[i] = Color(r,g,b)
				}
			}
		}
	}
	
	private subscript(a: Int, b: Int) -> Color {
		return pixels[min(max(b, 0), height-1) * width + min(max(a, 0), width-1)]
	}
	
	subscript(u: Scalar, v: Scalar ) -> Color {
		let a = u*Scalar(width)
		let b = v*Scalar(height)
		return self[Int(a), Int(b)]
	}
	
}
