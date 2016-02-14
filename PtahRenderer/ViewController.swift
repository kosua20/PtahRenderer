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
	override func viewDidLoad() {
		super.viewDidLoad()
		
		renderer = Renderer()
		let startTime = CFAbsoluteTimeGetCurrent();
		imageView.image = renderer.renderImage()
		print("[Total]: " + String(format: "%.4fs", CFAbsoluteTimeGetCurrent() - startTime))
		// Do any additional setup after loading the view.
		
	}

	override var representedObject: AnyObject? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}

