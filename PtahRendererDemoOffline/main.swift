//
//  main.swift
//  PtahRendererOffline
//
//  Created by Simon Rodriguez on 09/03/2016.
//  Copyright © 2016 Simon Rodriguez. All rights reserved.
//

import Foundation
import PtahRenderer
import PtahRendererDemo

print("Starting Ptah Renderer...")

let WIDTH = 800
let HEIGHT = 600
let ROOTDIR = FileManager.default.currentDirectoryPath + "/data/"

let renderer = Renderer(width: WIDTH, height: HEIGHT, rootDir: ROOTDIR)

renderer.render(elapsed: 0.0)

var pixels = renderer.flushBuffer()

let half = HEIGHT >> 1
for y in 0..<half {
	swap(&(pixels[y*WIDTH..<(y+1)*WIDTH]), &(pixels[WIDTH*(HEIGHT-y-1)..<WIDTH*(HEIGHT-y)]))
}

TGALoader.writeTGA(pixels: pixels, width: WIDTH, height: HEIGHT, path: ROOTDIR + "renders/im_\(time(nil)).tga")

print("Done!")
