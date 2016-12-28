//
//  ViewController.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 13/02/2016.
//  Copyright © 2016 Simon Rodriguez. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

	@IBOutlet weak var imageView: NSImageView!
	fileprivate var renderer : Renderer!
	fileprivate var timer: Timer!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.window?.title = "Ptah"
		
		// Size of the Cocoa view.
		let WIDTH = 500
		let HEIGHT = 350
		self.view.setFrameSize(NSSize(width: WIDTH, height: HEIGHT))
		self.imageView.setFrameSize(NSSize(width: WIDTH, height: HEIGHT))
		
		//Initialize renderer.
		renderer = Renderer(width: WIDTH,height: HEIGHT)
		
		//Launch the timer
		timer = Timer(timeInterval: 1.0 / 60.0, target: self, selector: #selector(ViewController.timerFired(_:)), userInfo: nil, repeats: true)
		RunLoop.current.add(timer, forMode: RunLoopMode.defaultRunLoopMode)
	}
	
	fileprivate var times : [Double] = Array(repeating: 0.0, count: 60)
	fileprivate var current = 0
	fileprivate var lastTime = CFAbsoluteTimeGetCurrent()
	
	func timerFired(_ sender: Timer!) {
		
		let startTime = CFAbsoluteTimeGetCurrent()
		
		renderer.clear()
		imageView.image = renderer.renderImage(elapsed: startTime - lastTime)
		
		lastTime = startTime
		
		let toc = CFAbsoluteTimeGetCurrent() - startTime
		print("[Full]: \t" + String(format: "%.4fs", toc))
		
		times[current] = toc
		current = (current + 1) % 60
		
		let avgFPS = 60.0 / times.reduce(0,+)
		print("⏲ \(Int(1/toc)) fps - Avg \(avgFPS) fps")
		print("-----------------------")
	}

	


}

