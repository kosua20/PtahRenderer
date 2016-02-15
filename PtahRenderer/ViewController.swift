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
		/*let startTime = CFAbsoluteTimeGetCurrent();
		imageView.image = renderer.renderImage()
		print("[Total]: " + String(format: "%.4fs", CFAbsoluteTimeGetCurrent() - startTime))
		// Do any additional setup after loading the view.*/
		//Launch the timer
		timer = NSTimer(timeInterval: 1.0 / 60.0, target: self, selector: "timerFired:", userInfo: nil, repeats: true)
		NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
	}
	
	func timerFired(sender: NSTimer!) {
			renderer.clear()
			imageView.image = renderer.renderImage()
	}

	override var representedObject: AnyObject? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}

