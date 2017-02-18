
import Foundation
import simd

func clip(_ faceClipSpace: Face) -> [Face] {
	
	var triangles : [Face] = []
	
	// All vertices are behind the camera.
	if faceClipSpace.v0.p.w <= 0.0 && faceClipSpace.v1.p.w <= 0.0 && faceClipSpace.v2.p.w <= 0.0 {
		return []
	}
	
	// All vertices are in front of the camera and inside the frustum.
	if faceClipSpace.v0.p.w > 0.0 && faceClipSpace.v1.p.w > 0.0 && faceClipSpace.v2.p.w > 0.0 &&
		abs(faceClipSpace.v0.p.z) < faceClipSpace.v0.p.w &&
		abs(faceClipSpace.v1.p.z) < faceClipSpace.v1.p.w &&
		abs(faceClipSpace.v2.p.z) < faceClipSpace.v2.p.w {
		
		triangles = [faceClipSpace]
		
	} else {
		// Clip each edge, accumulating vertices that we add or keep in an array.
		var vertices : [Vertex] = []
		clipEdge(v0: faceClipSpace.v0, v1: faceClipSpace.v1, vertices: &vertices)
		clipEdge(v0: faceClipSpace.v1, v1: faceClipSpace.v2,  vertices: &vertices)
		clipEdge(v0: faceClipSpace.v2, v1: faceClipSpace.v0, vertices: &vertices)
		
		// If not enough vertices to create a triangular face.
		if vertices.count < 3 {
			return []
		}
		// We potentially have a duplicate at the end, that we can remove.
		if vertices.last! == vertices.first! {
			vertices.remove(at: vertices.count - 1)
		}
		// Generate a fan of triangles, all sharing the first vertex.
		for i in 1..<vertices.count-1 {
			triangles.append(Face(v0: vertices[0], v1: vertices[i], v2: vertices[i+1]))
		}
	}
	return triangles
}




func clipEdge(v0: Vertex, v1: Vertex, vertices: inout [Vertex]){
	
	var v0New = v0
	var v1New = v1
	// Testing wrt near plane.
	let v0Inside = v0.p.w > 0.0 && v0.p.z > -v0.p.w
	let v1Inside = v1.p.w > 0.0 && v1.p.z > -v1.p.w
	
	if v0Inside && v1Inside {
		// Great, nothing to do.
	} else if v0Inside || v1Inside {
		// Compute interpolation coefficients.
		let d0 = v0.p.z + v0.p.w
		let d1 = v1.p.z + v1.p.w
		let factor = 1.0 / (d1 - d0)
		// New vertex with interpolated coefficients.
		let newVertex = Vertex(p: factor*(d1 * v0.p - d0 * v1.p),
		                       n: factor*(d1 * v0.n - d0 * v1.n),
		                       t: factor*(d1 * v0.t - d0 * v1.t))
		if v0Inside {
			v1New = newVertex
		} else {
			v0New = newVertex
		}
		
	} else {
		// Both are outside, on the same side. Remove the edge.
		return
	}
	// Add the first vertex if not already added.
	if vertices.count == 0 || !(vertices.last! == v0New) {
		vertices.append(v0New)
	}
	// Add the second vertex.
	vertices.append(v1New)
	
}

func cullFace(_ faceNormalizedSpace: Face) -> Bool {
	let d = (faceNormalizedSpace.v1.p.x - faceNormalizedSpace.v0.p.x) *
			(faceNormalizedSpace.v2.p.y - faceNormalizedSpace.v0.p.y) -
			(faceNormalizedSpace.v1.p.y - faceNormalizedSpace.v0.p.y) *
			(faceNormalizedSpace.v2.p.x - faceNormalizedSpace.v0.p.x)
	return d < 0.0
}




