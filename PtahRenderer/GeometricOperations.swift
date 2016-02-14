//
//  GeometricOperations.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 14/02/2016.
//  Copyright © 2016 Simon Rodriguez. All rights reserved.
//

import Foundation



/*--Barycentre-------*/

func barycentre(p : Point3f,_ v0 : Point3f,_ v1 : Point3f,_ v2 : Point3f) -> Point3f{
	let ab = v1 - v0
	let ac = v2 - v0
	let pa = v0 - p
	let uv1 = cross((ac.0,ab.0,pa.0),(ac.1,ab.1,pa.1))
	if abs(uv1.2) < 1.0 {
		return (-1,-1,-1)
	}
	return (1.0-(uv1.0+uv1.1)/uv1.2,uv1.1/uv1.2,uv1.0/uv1.2)
}

func barycentricInterpolation(coeffs : Point3f, t1 : Point2f, t2 : Point2f, t3 : Point2f) -> Point2f{
	return (coeffs.0 * t1.0 + coeffs.1 * t2.0 + coeffs.2 * t3.0,
		coeffs.0 * t1.1 + coeffs.1 * t2.1 + coeffs.2 * t3.1)
}

func barycentricInterpolation(coeffs : Point3f, t1 : Point3f, t2 : Point3f, t3 : Point3f) -> Point3f{
	return (coeffs.0 * t1.0 + coeffs.1 * t2.0 + coeffs.2 * t3.0,
		coeffs.0 * t1.1 + coeffs.1 * t2.1 + coeffs.2 * t3.1,
		coeffs.0 * t1.2 + coeffs.1 * t2.2 + coeffs.2 * t3.2)
}



/*--Bounding box-------------*/

func boundingBox(vs : [Point3f],_ width : Int,_ height : Int) -> (Point2f, Point2f){
	var mini  = (Scalar.infinity,Scalar.infinity)
	var maxi = (-Scalar.infinity,-Scalar.infinity)
	let lim = (Scalar(width-1),Scalar(height-1))
	for v in vs {
		mini.0 = max(min(mini.0,v.0),0)
		mini.1 = max(min(mini.1,v.1),0)
		maxi.0 = min(max(maxi.0,v.0),lim.0)
		maxi.1 = min(max(maxi.1,v.1),lim.1)
	}
	return (mini,maxi)
}