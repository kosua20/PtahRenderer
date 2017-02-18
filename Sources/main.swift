import Foundation
import simd



print("Loading data...")

let mesh = Mesh(named: "dragon")

let texture = Texture(named: "dragon")



print("Preparing the scene...")

let (width, height) : (Scalar, Scalar) = (800.0, 600.0)

let framebuffer = Framebuffer(w: width, h: height)

// Compute model-view-projection matrix.
let modelMatrix =  Matrix4.scaleMatrix(0.5) * Matrix4.rotationMatrix(angle: -1.7, axis: Point3(0.0,1.0,0.0))

let viewMatrix = Matrix4.lookAtMatrix(eye: Point3(-2.0,0.5,0.0), target: Point3(0.0), up: Point3(0.0,1.0,0.0))

let projectionMatrix = Matrix4.perspectiveMatrix(fov:70.0, aspect: width/height, near: 0.5, far: 10.0)

let mvpMatrix = projectionMatrix * viewMatrix * modelMatrix

let lightMatrix = modelMatrix.inverse.transpose



print("Rendering...")

// Fill the framebuffer with a constant background color.
framebuffer.clear(color: Color(0.1,0.1,0.1))

// For each face of the mesh...
for faceModelSpace in mesh.faces {
	
	// Transform the face into clip space.
	let faceClipSpace = worldSpaceToClipSpace(faceModelSpace, mvp: mvpMatrix, light: lightMatrix)
	
	// Perform clipping, potentially producing additional faces.
	let clippedFaces = clip(faceClipSpace)
	
	// For each of these...
	for clippedFace in clippedFaces {
	
		// Apply perspective division.
		let faceNDSpace = perspectiveDivide(clippedFace)
		
		// Check if the face is invisible and should be culled.
		if cullFace(faceNDSpace) { continue }
		
		// Transform the face into screen space.
		let faceScreenSpace = normalizedSpaceToScreenSpace(faceNDSpace, w: width, h: height)
		
		// Draw the face.
		draw(faceScreenSpace, into: framebuffer)
		
	}
	
}



print("Saving the image...")

let success = framebuffer.write(to: "result.tga")

print(success ? "Done!" : "Error while saving result.")

/*
print("Loading data...")

let mesh = Mesh(named: "dragon")

let texture = Texture(named: "dragon")



print("Preparing the scene...")

let (width, height) : (Scalar, Scalar) = (800.0, 600.0)

let framebuffer = Framebuffer(w: width, h: height)

let modelMatrix =  Matrix4.scaleMatrix(0.5) * Matrix4.rotationMatrix(angle: -1.7, axis: Point3(0.0,1.0,0.0))

let viewMatrix = Matrix4.lookAtMatrix(eye: Point3(-2.0,0.5,0.0), target: Point3(0.0), up: Point3(0.0,1.0,0.0))

let projectionMatrix = Matrix4.perspectiveMatrix(fov:70.0, aspect: width/height, near: 0.5, far: 10.0)

let mvpMatrix = projectionMatrix * viewMatrix * modelMatrix




print("Rendering...")

framebuffer.clear(color: Color(0.5,0.5,1.0))

for faceModelSpace in mesh.faces {
	
	let faceClipSpace = worldSpaceToClipSpace(faceModelSpace, mvp: mvpMatrix, light: lightMatrix)
	
	let clippedFaces = clip(faceClipSpace)
	
	for clippedFace in clippedFaces {
		
		let faceNDSpace = perspectiveDivide(clippedFace)
		
		if cullFace(faceNDSpace) { continue }
		
		let faceScreenSpace = normalizedSpaceToScreenSpace(faceNDSpace, w: width, h: height)
		
		draw(faceScreenSpace, into: framebuffer)

	}
	
}



print("Saving image...")

let success = framebuffer.write(to: "result.tga")

print(success ? "Done!" : "Error while saving result.")
*/
