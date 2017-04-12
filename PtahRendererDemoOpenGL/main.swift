import Foundation
import CoreFoundation
import PtahRenderer
import PtahRendererDemo


let WIDTH = 350
let HEIGHT = 220
let ROOTDIR = FileManager.default.currentDirectoryPath + "/data/"


let window = GLWindow(width: WIDTH, height: HEIGHT)
	
let renderer = Renderer(width: WIDTH, height: HEIGHT, rootDir: ROOTDIR)
	
var lastTime = CFAbsoluteTimeGetCurrent()

// Callbacks for camera movements.

func scrollCallback(yoffset: Double) {
	renderer.distance += Scalar(yoffset)*0.01
}

func dragCallback(deltaX: Double, deltaY: Double){
	renderer.horizontalAngle += Scalar(deltaX)*0.01
	renderer.verticalAngle += Scalar(deltaY)*0.01
	renderer.verticalAngle = clamp(renderer.verticalAngle, -1.57, 1.57)
}

// Main loop

while !window.shouldClose() {
	
	let startTime = CFAbsoluteTimeGetCurrent()
	renderer.render(elapsed: Scalar(startTime - lastTime))
	lastTime = startTime
	
	let pixels = renderer.flushBuffer().flatMap({[$0.r, $0.g, $0.b]})
	window.draw(pixels:pixels)
	
}



