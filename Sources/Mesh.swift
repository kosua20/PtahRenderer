
import Foundation


typealias Position = Point4
typealias Normal = Point4
typealias Color = Point3
typealias UV = Point2


struct Vertex {
	
	 let p: Position
	 let n: Normal
	 let t: UV
	
}


func ==(_ x: Vertex, _ y: Vertex) -> Bool {
	return x.p == y.p && x.n == y.n && x.t == y.t
}


struct Face {
	
	let v0: Vertex
	let v1: Vertex
	let v2: Vertex
	
	init(v0 _v0: Vertex, v1 _v1: Vertex, v2 _v2: Vertex){
		v0 = _v0; v1 = _v1; v2 = _v2
	}
	
	// Helper init to avoid manually replicating unchanged normals and texture coordinates when updating positions.
	init(p0: Position, p1: Position, p2: Position, face: Face){
		v0 = Vertex(p: p0, n: face.v0.n, t: face.v0.t)
		v1 = Vertex(p: p1, n: face.v1.n, t: face.v1.t)
		v2 = Vertex(p: p2, n: face.v2.n, t: face.v2.t)
	}
	
}


class Mesh {
	
	public var faces: [Face] = []
	
	
	init(named name: String) {
		let path = "Resources/" + name + ".obj"
		
		guard let lines = try? String(contentsOfFile: path, encoding: String.Encoding.utf8).components(separatedBy: CharacterSet.newlines) else {
			assertionFailure("Couldn't load the mesh")
			return
		}
		
		struct FaceIndices {
			let p: Int
			let t: Int
			let n: Int
		}
		
		var positions: [Position] = []
		var normals: [Normal] = []
		var uvs: [UV] = []
		var indices: [(FaceIndices, FaceIndices, FaceIndices)] = []
		
		for line in lines {
			let components = line.components(separatedBy: CharacterSet.whitespaces).filter({!$0.isEmpty})
			if (line.hasPrefix("v ")){
				// Position
				positions.append(Position(Scalar(components[1])!, Scalar(components[2])!, Scalar(components[3])!, /* w = */ 1.0))
			} else if (line.hasPrefix("vt ")) {
				// UV coordinates
				uvs.append(UV(Scalar(components[1])!, Scalar(components[2])!))
			} else if (line.hasPrefix("vn ")) {
				// Normal coordinates
				normals.append(Normal(Scalar(components[1])!, Scalar(components[2])!, Scalar(components[3])!, /* w = */ 0.0))
			} else if (line.hasPrefix("f ")) {
				//Face with positions/uvs/normals
				let splittedComponents = components.map({$0.components(separatedBy: "/")}).dropFirst()
				let intComps = splittedComponents.map({ $0.map({ $0 == "" ? 0 : Int($0)!})})
				let fi = intComps.map({ FaceIndices(p: $0[0]-1, t: $0[1]-1, n: $0[2]-1) })
				indices.append((fi[0], fi[1], fi[2]))
			}
		}
		// Expand indices, as vertices can have different normals/uvs depending on the face they are linked to.
		faces = indices.map({ Face(v0: Vertex(p: positions[$0.0.p], n: normals[$0.0.n], t: uvs[$0.0.t]),
		                           v1: Vertex(p: positions[$0.1.p], n: normals[$0.1.n], t: uvs[$0.1.t]),
		                           v2: Vertex(p: positions[$0.2.p], n: normals[$0.2.n], t: uvs[$0.2.t])) })
		
	}
	
}
