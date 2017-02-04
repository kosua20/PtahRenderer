//
//  Shaders.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 16/02/2016.
//  Copyright © 2016 Simon Rodriguez. All rights reserved.
//

import Foundation


public struct InputVertex {
	public let v: Vertex
	public let t: UV
	public let n: Normal
	
	public init(v iv: Vertex, t it: UV, n ni: Normal){
		v = iv
		t = it
		n = ni
	}
	
}


public struct OutputVertex {
	public var v: Point4
	public var t: UV
	public var n: Normal
	public var others : [Scalar]
	
	public init(v iv: Point4, t it: UV, n ni: Normal, others oi: [Scalar]){
		v = iv
		t = it
		n = ni
		others = oi
	}
	
}


public struct OutputFace {
	public let v0: OutputVertex
	public let v1: OutputVertex
	public let v2: OutputVertex
	
	public init(v0 iv0: OutputVertex, v1 iv1: OutputVertex, v2 iv2: OutputVertex){
		v0 = iv0
		v1 = iv1
		v2 = iv2
	}
	
}


public struct InputFragment {
	public let p: (Int, Int, Float)
	public let n: Normal
	public let t: UV
	public let others: [Scalar]
	
	public init(p ip:(Int, Int, Float), n ni: Normal, t it: UV, others oi: [Scalar]){
		p = ip
		n = ni
		t = it
		others = oi
	}
	
}



open class Program  {
	
	public var textures: [Texture] = []
	public var matrices: [Matrix4] = []
	public var points4: [Point4] = []
	public var points3: [Point3] = []
	public var points2: [Point2] = []
	public var scalars: [Scalar] = []
	public var buffers: [ScalarTexture] = []
	
	public init(){
		
	}
	
	open func vertexShader(_ input: InputVertex) -> OutputVertex { fatalError("Must Override") }
	
	open func fragmentShader(_ input: InputFragment) -> Color? { fatalError("Must Override") }
	
	public func register(index: Int = -1, value: Texture) { if index < 0 { textures.append(value) } else { textures[index] = value } }
	
	public func register(index: Int = -1, value: Matrix4) { if index < 0 { matrices.append(value) } else { matrices[index] = value } }
	
	public func register(index: Int = -1, value: Point4) { if index < 0 { points4.append(value) } else { points4[index] = value } }
	
	public func register(index: Int = -1, value: Point3) { if index < 0 { points3.append(value) } else { points3[index] = value } }
	
	public func register(index: Int = -1, value: Point2) { if index < 0 { points2.append(value) } else { points2[index] = value } }
	
	public func register(index: Int = -1, value: Scalar) { if index < 0 { scalars.append(value) } else { scalars[index] = value } }
	
	public func register(index: Int = -1, value: ScalarTexture) { if index < 0 { buffers.append(value) } else { buffers[index] = value } }
	
}


func ==(_ x: OutputVertex, _ y: OutputVertex) -> Bool {
	// Ignore 'others' attribute.
	return x.v == y.v && x.n == y.n && x.t == y.t
	
}


func !=(_ x: OutputVertex, _ y: OutputVertex) -> Bool {
	// Ignore 'others' attribute.
	return x.v != y.v || x.n != y.n || x.t != y.t
	
}
