
import Foundation


class Framebuffer {
	
	private var colorBuffer: [Color]
	private var depthBuffer: [Scalar]
	public let width: Int
	public let height: Int
	
	
	init(w: Scalar, h: Scalar){
		width = Int(w)
		height = Int(h)
		colorBuffer = [Color](repeating: Color(0.0), count: width*height)
		depthBuffer = [Scalar](repeating: 1.0, count: width*height)
	}
	
	func getDepth(_ x: Int, _ y: Int) -> Scalar {
		return depthBuffer[y * width + x]
	}
	
	func setDepth(_ x: Int, _ y: Int, _ depth: Scalar){
		depthBuffer[y * width + x] = depth
	}
	
	func setColor(_ x: Int, _ y: Int, _ color: Color){
		colorBuffer[y * width + x] = color
	}
	
	func clear(color: Color = Color(0.0)){
		for i in 0..<width*height {
			colorBuffer[i] = color
			depthBuffer[i] = 1.0
		}
	}
	
	func write(to path: String) -> Bool {
		
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
		
		let pixeldata = colorBuffer.flatMap({[UInt8( max(min($0.z*255, 255), 0)),
		                                      UInt8( max(min($0.y*255, 255), 0)),
		                                      UInt8( max(min($0.x*255, 255), 0))]})
		data.append(pixeldata, length: imageLength)
		return data.write(toFile: path.hasSuffix(".tga") ? path: (path + ".tga") , atomically: true)
		
	}
	
}
