# PtahRenderer

A small software graphics renderer. Offline and online demos available on macOS and Linux (tested on Ubuntu). See [Programs](#Programs) for requirements and build instructions.

![](images/icon.png)

Written with the help of (among other resources) :

- *Interactive Computer Graphics - A Top-Down Approach*, 2012, E. Angel & D.Shreiner
- *Introduction to Computer Graphics* course, M. Pauly, EPFL 2015
- *How OpenGL works*, D. V. Sokolov, available at [github.com/ssloy/tinyrenderer](https://github.com/ssloy/tinyrenderer/wiki)
- *Triangle rasterization in practice* and the following posts, F. Giesen, available [here](https://fgiesen.wordpress.com/2013/02/08/triangle-rasterization-in-practice/)
- *Rasterization: a Practical Implementation*, , available at [scratchapixel.com](https://www.scratchapixel.com/lessons/3d-basic-rendering/rasterization-practical-implementation/overview-rasterization-algorithm)
- *How to write a (software) 3d polygon pipeline*, C. Bloom, available [here](http://www.cbloom.com/3d/techdocs/pipeline.txt)


![Image produced with the software renderer](images/header.png)

### Programs

The project is composed of two library modules, and three programs:

- **PtahRenderer** contains the internal logic to perform transformation, rasterization and clipping,... along with primitive types.
- **PtahRendererDemo** contains the scene, the objects and shaders, and handles camera movements and animations.
- **PtahRendererDemoOffline** is a command-line utility that renders one frame of the scene and saves it to a `.tga` file in the `renders/` directory 
- **PtahRendererDemoOnline** is a macOS Cocoa application (that can only be built using Xcode), performing real-time rendering with mouse interactions (scroll to zoom, drag to rotate around the scene).
- **PtahRendererDemoOpenGL** performs the same tasks as PtahRendererDemoOnline but relies on OpenGL 3 and GLFW 3 to display the output of the renderer in real-time.

Apart from PtahRendererDemoOnline, everything can be compiled using the Swift Package Manager on both macOS (tested on macOS 10.12) and Linux (tested on Ubuntu 16.04). 

	swift build -c release -Xlinker -L/usr/local/lib
	 
For PtahRendererDemoOpenGL, GLFW 3 needs to be installed in `/usr/local` and is accessed through a thin wrapper ([macOS](https://github.com/kosua20/CGLFW3) and [Linux](https://github.com/kosua20/CGLFW3Linux) versions). OpenGL is also used through a wrapper, [JFOpenGL](https://github.com/jaz303/JFOpenGL.swift), that mainly provides platform independance and types simplification (because of Swift handling of GLenum among other things).

### Done
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
* Offline demo (both platforms)
* Real-time demo (both platforms)

### To do
* Optimizations...