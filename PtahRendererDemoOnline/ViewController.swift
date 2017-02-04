//
//  ViewController.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 13/02/2016.
//  Copyright © 2016 Simon Rodriguez. All rights reserved.
//

import Cocoa
import PtahRenderer
import PtahRendererDemo

let WIDTH = 256
let HEIGHT = 192
let ROOTDIR = FileManager.default.currentDirectoryPath + "/data/"

class ViewController: NSViewController {

	fileprivate var renderer: Renderer!
	fileprivate var timer: Timer!
	fileprivate var lastTime = CFAbsoluteTimeGetCurrent()
	fileprivate var times: [Double] = Array(repeating: 0.0, count: 60)
	fileprivate var current = 0
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		self.view.window?.title = "Ptah"
		
		// Size of the Cocoa view.
		self.view.setFrameSize(NSSize(width: WIDTH, height: HEIGHT))
		
		// Initialize renderer.
		renderer = Renderer(width: WIDTH, height: HEIGHT, rootDir: ROOTDIR)
		self.view.layer?.magnificationFilter = kCAFilterNearest
		// Create timer with callback.
		timer = Timer(timeInterval: 1.0 / 60.0, target: self, selector: #selector(ViewController.timerFired(_:)), userInfo: nil, repeats: true)
		// Launch timer.s
		RunLoop.current.add(timer, forMode: RunLoopMode.defaultRunLoopMode)
		lastTime = CFAbsoluteTimeGetCurrent()
		
	}
	
	
	func timerFired(_ sender: Timer!) {
		
		let startTime = CFAbsoluteTimeGetCurrent()
		
		// Render.
		renderer.render(elapsed: Scalar(startTime - lastTime))
		
		// Flush.
		self.view.layer?.contents = renderer.flush()
		lastTime = startTime
	
		// Framerate display.
		let toc = CFAbsoluteTimeGetCurrent() - startTime
		times[current] = toc
		current = (current + 1) % 60
		let avgFPS = 60.0 / times.reduce(0, +)
		print("⏲ \(Int(1/toc)) fps - Avg \(avgFPS) fps")
	
	}

	
	
	override func mouseDragged(with event: NSEvent) {
		
		super.mouseDragged(with: event)
		renderer.horizontalAngle += Scalar(event.deltaX)*0.01
		renderer.verticalAngle += Scalar(event.deltaY)*0.01
		renderer.verticalAngle = clamp(renderer.verticalAngle, -1.57, 1.57)
		
	}
	
	
	override func scrollWheel(with event: NSEvent) {
		
		super.scrollWheel(with: event)
		renderer.distance += Scalar(event.deltaY)*0.01
		
	}

	
}

