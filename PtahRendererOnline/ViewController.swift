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
	private var renderer : Renderer!
	private var timer: NSTimer!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		renderer = Renderer(width: 512,height: 512)
		//Launch the timer
		timer = NSTimer(timeInterval: 1.0 / 60.0, target: self, selector: "timerFired:", userInfo: nil, repeats: true)
		NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
		
		
		
	}
	
	private var avg = 0
	private var count = 0
	
	func timerFired(sender: NSTimer!) {
		let startTime = CFAbsoluteTimeGetCurrent();
			renderer.clear()
			imageView.image = renderer.renderImage()
		let toc = CFAbsoluteTimeGetCurrent() - startTime
		print("[Full]: \t" + String(format: "%.4fs", toc))
		let fps = Int(1/toc)
		avg += fps
		count += 1
		print("⏲ \(fps) fps - Avg \(avg/count) fps")
		print("-----------------------")
		self.view.window?.title = "Ptah - ⏲ \(fps) fps"
	}

	override var representedObject: AnyObject? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}

