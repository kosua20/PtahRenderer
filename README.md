# PtahRenderer

A small software graphics renderer. Offline demo available on macOS and Linux (tested on Ubuntu), real-time demo on macOS only.
Project can be built with the Swift Package Manager (`swift build`) on all platforms, or with Xcode (`PtahRenderer.xcodeproj`) on macOS.

![](images/icon.png)

Written with the help of (among other things) :

- *Interactive Computer Graphics - A Top-Down Approach*, 2012, E. Angel & D.Shreiner
- *Introduction to Computer Graphics* course, M. Pauly, EPFL 2015
- *How OpenGL works*, D. V. Sokolov, available at [github.com/ssloy/tinyrenderer](https://github.com/ssloy/tinyrenderer/wiki)
- *Triangle rasterization in practice* and the following posts, F. Giesen, available [here](https://fgiesen.wordpress.com/2013/02/08/triangle-rasterization-in-practice/)
- *Rasterization: a Practical Implementation*, , available at [scratchapixel.com](https://www.scratchapixel.com/lessons/3d-basic-rendering/rasterization-practical-implementation/overview-rasterization-algorithm)
- *How to write a (software) 3d polygon pipeline*, C. Bloom, available [here](http://www.cbloom.com/3d/techdocs/pipeline.txt)


![Image produced with the software renderer](images/header.png)

###Done
* General setup
* Mesh loading (OBJ with vertices, normals, texture coordinates, faces)
* Texture loading (PNG, 1-3-4 channels, supports wrapping and clamping)
* Line drawing (using Bresenham’s line drawing algorithm)
* Wireframe drawing for triangular faces
* Triangles rasterization
* Z-buffer
* View and world matrices
* Back faces culling
* Projection matrix
* Primitives clipping
* Shaders (vertex, fragment)
* Multi pass (for AO (SSAO or pre-computation), shadow maps, deferred shading)
* Offline demo
* Real-time demo



###To do
* Optimizations...