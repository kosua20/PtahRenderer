//
//  main.swift
//  PtahRendererOffline
//
//  Created by Simon Rodriguez on 09/03/2016.
//  Copyright © 2016 Simon Rodriguez. All rights reserved.
//

import Foundation
print("Starting Ptah Renderer...")

let renderer = Renderer(width: 512,height: 512)
renderer.clear()

let pixels = renderer.renderBuffer()

let tim = time(nil)
TGALoader.writeTGA(pixels, width: 512, height: 512, path: rootDir + "renders/im_\(tim).tga")

print("Done!")