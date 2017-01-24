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
	let uv1 = cross(Point3(ac.x, ab.x, pa.x), Point3(ac.y, ab.y, pa.y))
	if abs(uv1.z) < 1e-2 {
		return Point3(-1, 1, 1)
	}
	return (1.0/uv1.z)*Point3(uv1.z-(uv1.x+uv1.y), uv1.y, uv1.x)

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
	
	var mini  = Point2(Scalar.infinity, Scalar.infinity)
	var maxi = Point2(-Scalar.infinity, -Scalar.infinity)
	let lim = Point2(Scalar(width-1), Scalar(height-1))
	

	for v in vs {
		let v2 = Point2(v.x, v.y)
		mini = min(mini, v2)
		maxi = max(maxi, v2)
		
	}
	
	let finalMin = clamp(min(mini,maxi), min: Point2(0.0), max: lim)
	let finalMax = clamp(max(mini,maxi), min: Point2(0.0), max: lim)
	
	return (finalMin, finalMax)
	
}
