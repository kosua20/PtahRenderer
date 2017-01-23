//
//  Geometry.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 14/02/2016.
//  Copyright © 2016 Simon Rodriguez. All rights reserved.
//

import Foundation
import simd

/*--Barycentre-------*/

func barycentre(_ p: Point3, _ v0: Point3, _ v1: Point3, _ v2: Point3) -> Point3{

	let ab = v1 - v0
	let ac = v2 - v0
	let pa = v0 - p
	let uv1 = cross(float3(ac.x, ab.x, pa.x), float3(ac.y, ab.y, pa.y))
	if abs(uv1.z) < 1e-2 {
		return float3(-1, 1, 1)
	}
	return (1.0/uv1.z)*float3(uv1.z-(uv1.x+uv1.y), uv1.y, uv1.x)

}


func barycentricInterpolation(coeffs: Point3, t1: Point2, t2: Point2, t3: Point2) -> Point2{

	return coeffs.x * t1 + coeffs.y * t2 + coeffs.z * t3

}


func barycentricInterpolation(coeffs: Point3, t1: Point3, t2: Point3, t3: Point3) -> Point3{

	return coeffs.x * t1 + coeffs.y * t2 + coeffs.z * t3

}


func barycentricInterpolation(coeffs: Point3, t1: [Scalar], t2: [Scalar], t3: [Scalar]) -> [Scalar]{
	
	var newOthers : [Scalar] = []
	for i in 0..<t1.count {
		newOthers.append(coeffs.x * t1[i] + coeffs.y * t2[i] + coeffs.z * t3[i])
	}
	return newOthers

}


/*--Bounding box-------------*/

func boundingBox(_ vs: [Point3], _ width: Int, _ height: Int) -> (Point2, Point2){
	
	var mini  = float2(Scalar.infinity, Scalar.infinity)
	var maxi = float2(-Scalar.infinity, -Scalar.infinity)
	let lim = float2(Scalar(width-1), Scalar(height-1))
	

	for v in vs {
		let v2 = float2(v.x, v.y)
		mini = min(mini, v2)
		maxi = max(maxi, v2)
		/*mini.0 = min(mini.0, v.0)
		mini.1 = min(mini.1, v.1)
		maxi.0 = max(maxi.0, v.0)
		maxi.1 = max(maxi.1, v.1)*/
	}
	
	/*let finalMinX = clamp(min(mini.0, maxi.0), 0, lim.0)
	let finalMinY = clamp(min(mini.1, maxi.1), 0, lim.1)
	let finalMaxX = clamp(max(mini.0, maxi.0), 0, lim.0)
	let finalMaxY = clamp(max(mini.1, maxi.1), 0, lim.1)*/
	
	let finalMin = clamp(min(mini,maxi), min: float2(0.0), max: lim)
	let finalMax = clamp(max(mini,maxi), min: float2(0.0), max: lim)
	
	return (finalMin, finalMax)
	
}
