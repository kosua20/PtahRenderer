//
//  Point.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 14/02/2016.
//  Copyright © 2016 Simon Rodriguez. All rights reserved.
//

import Foundation

#if os(macOS)
import simd
#endif

#if os(macOS)
public typealias Point4 = float4
public typealias Point3 = float3
public typealias Point2 = float2
#else
public typealias Point4 = internal_float4
public typealias Point3 = internal_float3
public typealias Point2 = internal_float2
#endif

public typealias Scalar = Float
public typealias Vertex = Point3
public typealias Normal = Point3
public typealias UV = Point2



public func ==(lhs: Point2, rhs: Point2) -> Bool {
	
	return lhs.x == rhs.x && lhs.y == rhs.y

}


public func !=(lhs: Point2, rhs: Point2) -> Bool {

	return lhs.x != rhs.x || lhs.y != rhs.y

}


public func ==(lhs: Point3, rhs: Point3) -> Bool {

	return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z

}


public func !=(lhs: Point3, rhs: Point3) -> Bool {
	
	return lhs.x != rhs.x || lhs.y != rhs.y || lhs.z != rhs.z

}


public func ==(lhs: Point4, rhs: Point4) -> Bool {

	return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z && lhs.w == rhs.w

}


public func !=(lhs: Point4, rhs: Point4) -> Bool {

	return lhs.x != rhs.x || lhs.y != rhs.y || lhs.z != rhs.z || lhs.w != rhs.w

}


public func clamp(_ x: Scalar, _ a: Scalar, _ b: Scalar) -> Scalar {
	
	return min(b, max(a, x))
	
}


public func clamp(_ x: UInt8, _ a: UInt8, _ b: UInt8) -> UInt8 {
	
	return min(b, max(a, x))
	
}


public func clamp(_ x: Int, _ a: Int, _ b: Int) -> Int {
	
	return min(b, max(a, x))
	
}



public  extension Point3 {
	
	public  init(_ v: Point4) {
		
		self.init(v.x, v.y, v.z)
		
	}
}


public  extension Point4 {
	
	public  init(_ v: Point3, _ wval: Float) {
		
		self.init()
		x = v.x
		y = v.y
		z = v.z
		w = wval
		
	}
	
}

/// MARK: Internal fallback

#if os(macOS)
	// Rely on simd
#else

public struct internal_float2 {
	
	public var x: Scalar = 0.0
	public var y: Scalar = 0.0
	
	
	public init() {
		
	}
	
	
	public init(_ val: Scalar){
		
		x = val
		y = val
	}
	
	
	public init(_ _x: Scalar, _ _y: Scalar) {
		
		x = _x
		y = _y
		
	}
}

public func +(lhs: internal_float2, rhs: internal_float2) -> internal_float2 {
	return internal_float2(lhs.x + rhs.x, lhs.y + rhs.y)
}

public func -(lhs: internal_float2, rhs: internal_float2) -> internal_float2 {
	return internal_float2(lhs.x - rhs.x, lhs.y-rhs.y)
}

public prefix func -(rhs: internal_float2) -> internal_float2 {
	return internal_float2(-rhs.x, -rhs.y)
}

public func *(lhs: Scalar, rhs: internal_float2) -> internal_float2 {
	return internal_float2(lhs*rhs.x, lhs*rhs.y)
}

public func *(rhs: internal_float2, lhs: Scalar) -> internal_float2 {
	return internal_float2(lhs*rhs.x, lhs*rhs.y)
}

public func min(_ lhs: internal_float2, _ rhs: internal_float2) -> internal_float2 {
	return internal_float2(min(lhs.x, rhs.x), min(lhs.y, rhs.y))
}

public func max(_ lhs: internal_float2, _ rhs: internal_float2) -> internal_float2 {
	return internal_float2(max(lhs.x, rhs.x), max(lhs.y, rhs.y))
}

public func abs(_ lhs: internal_float2) -> internal_float2 {
	return internal_float2(abs(lhs.x), abs(lhs.y))
}

public func clamp(_ lhs: internal_float2, min mini: internal_float2, max maxi: internal_float2) -> internal_float2 {
	return min(maxi, max(mini, lhs))
}

public func clamp(_ lhs: internal_float2, min mini: Scalar, max maxi: Scalar) -> internal_float2 {
	return internal_float2(min(maxi, max(mini, lhs.x)), min(maxi, max(mini, lhs.y)))
}


public struct internal_float3 {
	
	public var x: Scalar = 0.0
	public var y: Scalar = 0.0
	public var z: Scalar = 0.0
	
	
	public init() {
		
	}
	
	
	public init(_ val: Scalar){
		
		x = val
		y = val
		z = val
	}
	
	
	public init(_ _x: Scalar, _ _y: Scalar, _ _z: Scalar) {
		
		x = _x
		y = _y
		z = _z
		
	}
	
}



public func +(lhs: internal_float3, rhs: internal_float3) -> internal_float3 {
	return internal_float3(lhs.x + rhs.x, lhs.y+rhs.y, lhs.z+rhs.z)
}

public func -(lhs: internal_float3, rhs: internal_float3) -> internal_float3 {
	return internal_float3(lhs.x - rhs.x, lhs.y-rhs.y, lhs.z-rhs.z)
}

public prefix func -(rhs: internal_float3) -> internal_float3 {
	return internal_float3(-rhs.x, -rhs.y, -rhs.z)
}

public func *(lhs: Scalar, rhs: internal_float3) -> internal_float3 {
	return internal_float3(lhs*rhs.x, lhs*rhs.y, lhs*rhs.z)
}

public func *(rhs: internal_float3, lhs: Scalar) -> internal_float3 {
	return internal_float3(lhs*rhs.x, lhs*rhs.y, lhs*rhs.z)
}

public func min(_ lhs: internal_float3, _ rhs: internal_float3) -> internal_float3 {
	return internal_float3(min(lhs.x, rhs.x), min(lhs.y, rhs.y), min(lhs.z, rhs.z))
}

public func max(_ lhs: internal_float3, _ rhs: internal_float3) -> internal_float3 {
	return internal_float3(max(lhs.x, rhs.x), max(lhs.y, rhs.y), max(lhs.z, rhs.z))
}

public func abs(_ lhs: internal_float3) -> internal_float3 {
	return internal_float3(abs(lhs.x), abs(lhs.y), abs(lhs.z))
}

public func clamp(_ lhs: internal_float3, min mini: internal_float3, max maxi: internal_float3) -> internal_float3 {
	return min(maxi, max(mini, lhs))
}

public func clamp(_ lhs: internal_float3, min mini: Scalar, max maxi: Scalar) -> internal_float3 {
	return internal_float3(min(maxi, max(mini, lhs.x)), min(maxi, max(mini, lhs.y)), min(maxi, max(mini, lhs.z)))
}

public func cross(_ lhs: internal_float3, _ rhs: internal_float3) -> internal_float3 {
	return internal_float3(lhs.y*rhs.z - lhs.z*rhs.y, lhs.z*rhs.x - lhs.x*rhs.z, lhs.x*rhs.y - lhs.y*rhs.x)
}

public func dot(_ lhs: internal_float3, _ rhs: internal_float3) -> Scalar {
	return lhs.x*rhs.x+lhs.y*rhs.y+lhs.z*rhs.z
}

public func normalize(_ n: internal_float3) -> internal_float3 {
	let norm = sqrt(dot(n, n))
	if(norm==0.0){
		return n
	}
	return (1.0/norm)*n
}

public func reflect(_ lhs: internal_float3, n rhs: internal_float3) -> internal_float3 {
	return lhs - 2.0 * dot(rhs, lhs) * rhs
}




public struct internal_float4 {
	
	public var x: Scalar = 0.0
	public var y: Scalar = 0.0
	public var z: Scalar = 0.0
	public var w: Scalar = 0.0
	
	
	public init() {
		
	}
	
	
	public init(_ val: Scalar){
		
		x = val
		y = val
		z = val
		w = val
	}
	
	
	public init(_ _x: Scalar, _ _y: Scalar, _ _z: Scalar, _ _w: Scalar) {
		
		x = _x
		y = _y
		z = _z
		w = _w
		
	}
	
}

public func +(lhs: internal_float4, rhs: internal_float4) -> internal_float4 {
	return internal_float4(lhs.x + rhs.x, lhs.y+rhs.y, lhs.z+rhs.z, lhs.w+rhs.w)
}

public func -(lhs: internal_float4, rhs: internal_float4) -> internal_float4 {
	return internal_float4(lhs.x - rhs.x, lhs.y-rhs.y, lhs.z-rhs.z, lhs.w-rhs.w)
}

public prefix func -(rhs: internal_float4) -> internal_float4 {
	return internal_float4(-rhs.x, -rhs.y, -rhs.z, -rhs.w)
}

public func *(lhs: Scalar, rhs: internal_float4) -> internal_float4 {
	return internal_float4(lhs*rhs.x, lhs*rhs.y, lhs*rhs.z, lhs*rhs.w)
}

public func *(rhs: internal_float4, lhs: Scalar) -> internal_float4 {
	return internal_float4(lhs*rhs.x, lhs*rhs.y, lhs*rhs.z, lhs*rhs.w)
}

public func min(_ lhs: internal_float4, _ rhs: internal_float4) -> internal_float4 {
	return internal_float4(min(lhs.x, rhs.x), min(lhs.y, rhs.y), min(lhs.z, rhs.z), min(lhs.w, rhs.w))
}

public func max(_ lhs: internal_float4, _ rhs: internal_float4) -> internal_float4 {
	return internal_float4(max(lhs.x, rhs.x), max(lhs.y, rhs.y), max(lhs.z, rhs.z), max(lhs.w, rhs.w))
}

public func abs(_ lhs: internal_float4) -> internal_float4 {
	return internal_float4(abs(lhs.x), abs(lhs.y), abs(lhs.z), abs(lhs.w))
}

public func clamp(_ lhs: internal_float4, min mini: internal_float4, max maxi: internal_float4) -> internal_float4 {
	return min(maxi, max(mini, lhs))
}

public func clamp(_ lhs: internal_float4, min mini: Scalar, max maxi: Scalar) -> internal_float4 {
	return internal_float4(min(maxi, max(mini, lhs.x)), min(maxi, max(mini, lhs.y)), min(maxi, max(mini, lhs.z)), min(maxi, max(mini, lhs.w)))
}


#endif
