
import Foundation
import simd


// MARK: Vertices transformations.

func worldSpaceToClipSpace(_ faceModelSpace: Face, mvp matrix: Matrix4, light lightMatrix: Matrix4) -> Face {
	let v0 = Vertex(p: matrix * faceModelSpace.v0.p,
	                n: lightMatrix * faceModelSpace.v0.n,
	                t: faceModelSpace.v0.t)
	let v1 = Vertex(p: matrix * faceModelSpace.v1.p,
	                n: lightMatrix * faceModelSpace.v1.n,
	                t: faceModelSpace.v1.t)
	let v2 = Vertex(p: matrix * faceModelSpace.v2.p,
	                n: lightMatrix * faceModelSpace.v2.n,
	                t: faceModelSpace.v2.t)
	
	return Face(v0: v0, v1: v1, v2: v2)
}

func perspectiveDivide(_ faceClipSpace: Face) -> Face {
	let p0NormalizedSpace = Point4(faceClipSpace.v0.p.x / faceClipSpace.v0.p.w,
	                       faceClipSpace.v0.p.y / faceClipSpace.v0.p.w,
	                       faceClipSpace.v0.p.z / faceClipSpace.v0.p.w,
	                       faceClipSpace.v0.p.w)
	let p1NormalizedSpace = Point4(faceClipSpace.v1.p.x / faceClipSpace.v1.p.w,
	                       faceClipSpace.v1.p.y / faceClipSpace.v1.p.w,
	                       faceClipSpace.v1.p.z / faceClipSpace.v1.p.w,
	                       faceClipSpace.v1.p.w)
	let p2NormalizedSpace = Point4(faceClipSpace.v2.p.x / faceClipSpace.v2.p.w,
	                       faceClipSpace.v2.p.y / faceClipSpace.v2.p.w,
	                       faceClipSpace.v2.p.z / faceClipSpace.v2.p.w,
	                       faceClipSpace.v2.p.w)
	
	return Face(p0: p0NormalizedSpace, p1: p1NormalizedSpace, p2: p2NormalizedSpace, face: faceClipSpace)
}

func normalizedSpaceToScreenSpace(_ faceNormalizedSpace: Face, w width: Scalar, h height: Scalar) -> Face {
	let p0ScreenSpace = Point4(	floor(0.5 * width  * (faceNormalizedSpace.v0.p.x + 1.0)),
	                           	floor(0.5 * height * (faceNormalizedSpace.v0.p.y + 1.0)),
	                           	faceNormalizedSpace.v0.p.z,
	                           	faceNormalizedSpace.v0.p.w)
	let p1ScreenSpace = Point4(	floor(0.5 * width  * (faceNormalizedSpace.v1.p.x + 1.0)),
	                           	floor(0.5 * height * (faceNormalizedSpace.v1.p.y + 1.0)),
	                           	faceNormalizedSpace.v1.p.z,
	                           	faceNormalizedSpace.v1.p.w)
	let p2ScreenSpace = Point4(	floor(0.5 * width  * (faceNormalizedSpace.v2.p.x + 1.0)),
	                           	floor(0.5 * height * (faceNormalizedSpace.v2.p.y + 1.0)),
	                           	faceNormalizedSpace.v2.p.z,
	                           	faceNormalizedSpace.v2.p.w)
	
	return Face(p0: p0ScreenSpace, p1: p1ScreenSpace, p2: p2ScreenSpace, face: faceNormalizedSpace)
}


// MARK: Drawing a face.

func draw(_ fScreen: Face, into framebuffer: Framebuffer){
	// Compute clamped bounding box.
	let (mini, maxi) = boundingBox(fScreen, framebuffer.width, framebuffer.height)
	// Iterate over the pixels in the box.
	for x in Int(mini.x)...Int(maxi.x) {
		for y in Int(mini.y)...Int(maxi.y) {
			// Compute the barycentric coordinates of the current pixel.
			let bary = barycentre(Point2(Scalar(x), Scalar(y)), fScreen.v0.p, fScreen.v1.p, fScreen.v2.p)
			// If one of them is negative, we are outside the triangle.
			if bary.x < 0.0 || bary.y < 0.0 || bary.z < 0.0 { continue }
			// Interpolate depth at the current pixel.
			let z = fScreen.v0.p.z * bary.x + fScreen.v1.p.z * bary.y + fScreen.v2.p.z * bary.z
			// If the current triangle pixel is closer than the last one drawn.
			if z < framebuffer.getDepth(x, y) {
				// Compute perspective correct interpolation coefficients.
				var persp = Point3(bary.x/fScreen.v0.p.w, bary.y/fScreen.v1.p.w, bary.z/fScreen.v2.p.w)
				persp = (1.0 / (persp.x + persp.y + persp.z)) * persp
				// Perspective interpolation of texture coordinates and normal.
				let tex = persp.x * fScreen.v0.t + persp.y * fScreen.v1.t + persp.z * fScreen.v2.t
				let nor = persp.x * fScreen.v0.n + persp.y * fScreen.v1.n + persp.z * fScreen.v2.n
				// Compute the color: use a diffuse factor with a strong light intensity.
				let diffuse = 1.5*max(0.0, dot(normalize(Point3(nor.x, nor.y, nor.z)), normalize(Point3(0.0,1.0, 1.0))))
				let color = diffuse*texture[tex.x, tex.y]
				// Set color and depth.
				framebuffer.setColor(x, y, color)
				framebuffer.setDepth(x, y, z)
			}
		}
	}
}

func boundingBox(_ vs: Face, _ width: Int, _ height: Int) -> (Point2, Point2){
	// We work only in the (x,y) plane.
	let v0ScreenSpace = Point2(vs.v0.p.x, vs.v0.p.y)
	let v1ScreenSpace = Point2(vs.v1.p.x, vs.v1.p.y)
	let v2ScreenSpace = Point2(vs.v2.p.x, vs.v2.p.y)
	// Find minimal and maximal points.
	let mini = min(min(v0ScreenSpace, v1ScreenSpace), v2ScreenSpace)
	let maxi = max(max(v0ScreenSpace, v1ScreenSpace), v2ScreenSpace)
	// Framebuffer bounds.
	let lim = Point2(Scalar(width) - 1.0, Scalar(height) - 1.0)
	// Clamp the bounding box against the framebuffer.
	let finalMin = clamp(min(mini,maxi), min: Point2(0.0), max: lim)
	let finalMax = clamp(max(mini,maxi), min: Point2(0.0), max: lim)
	return (finalMin, finalMax)
}

func barycentre(_ p: Point2, _ v0: Point4, _ v1: Point4, _ v2: Point4) -> Point3 {
	// v0 will be the origin.
	// ab and ac: basis vectors.
	let ab = v1 - v0
	let ac = v2 - v0
	// pa: vector with p coordinates in the barycentric frame.
	let pa = Point2(v0.x, v0.y) - p
	// magic ?
	let uv1 = cross(Point3(ac.x, ab.x, pa.x), Point3(ac.y, ab.y, pa.y))
	// Avoid division imprecision.
	if abs(uv1.z) < 1e-2 { return Point3(-1, 1, 1) }
	// Combine.
	return (1.0/uv1.z)*Point3(uv1.z-(uv1.x+uv1.y), uv1.y, uv1.x)
	
}



