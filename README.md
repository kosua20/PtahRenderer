# PtahRenderer
A small software graphics renderer

Work in progress, using (among other things) :

- *Interactive Computer Graphics - A Top-Down Approach*, 2012, E. Angel & D.Shreiner
- *Introduction to Computer Graphics* course, M. Pauly, EPFL 2015
- *How OpenGL works*, D. V. Sokolov, available at [github.com/ssloy/tinyrenderer](https://github.com/ssloy/tinyrenderer/wiki)

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

###To do
* Primitives clipping
* Shaders (vertex, fragment)
* Multi pass (for AO (SSAO or pre-computation), shadow maps, deferred shading)
* ...