//
//  GeometricTypes.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 14/02/2016.
//  Copyright © 2016 Simon Rodriguez. All rights reserved.
//

import Foundation

typealias Point3 = (Scalar, Scalar, Scalar)
typealias Point2 = (Scalar, Scalar)
typealias Vertex = Point3
typealias Normal = Point3
typealias UV = Point2



/*--Point3--------*/

func +(lhs : Point3, rhs : Point3) -> Point3 {
	return (lhs.0 + rhs.0,lhs.1+rhs.1,lhs.2+rhs.2)
}

func +=(inout lhs : Point3, rhs : Point3) {
	lhs.0 += rhs.0
	lhs.1 += rhs.1
	lhs.2 += rhs.2
}

func -(lhs : Point3, rhs : Point3) -> Point3 {
	return (lhs.0 - rhs.0,lhs.1-rhs.1,lhs.2-rhs.2)
}

func -=(inout lhs : Point3, rhs : Point3) {
	lhs.0 -= rhs.0
	lhs.1 -= rhs.1
	lhs.2 -= rhs.2
}

func *(lhs : Scalar, rhs : Point3) -> Point3 {
	return (lhs*rhs.0,lhs*rhs.1,lhs*rhs.2)
}

func *(rhs : Point3, lhs : Scalar) -> Point3 {
	return (lhs*rhs.0,lhs*rhs.1,lhs*rhs.2)
}

func *=(inout lhs : Point3, rhs : Scalar){
	lhs.0 = lhs.0*rhs
	lhs.1 = lhs.1*rhs
	lhs.2 = lhs.2*rhs
}

func /(rhs : Point3, lhs : Scalar) -> Point3 {
	return (rhs.0/lhs,rhs.1/lhs,rhs.2/lhs)
}

func /=(inout lhs : Point3, rhs : Scalar){
	lhs.0 = lhs.0/rhs
	lhs.1 = lhs.1/rhs
	lhs.2 = lhs.2/rhs
}


func cross(lhs : Point3,_ rhs : Point3) -> Point3 {
	return (lhs.1*rhs.2 - lhs.2*rhs.1,lhs.2*rhs.0 - lhs.0*rhs.2,lhs.0*rhs.1 - lhs.1*rhs.0)
}

func dot(lhs : Point3, _ rhs : Point3) -> Scalar {
	return lhs.0*rhs.0+lhs.1*rhs.1+lhs.2*rhs.2
}

func norm(lhs : Point3) -> Scalar {
	return sqrt(dot(lhs,lhs))
}

func norm2(lhs : Point3) -> Scalar {
	return dot(lhs,lhs)
}

func normalize(inout n : Point3){
	let norm = sqrt(dot(n,n))
	if(norm==0.0){ return }
	n /= norm
}

func normalized(n : Point3) -> Point3 {
	let norm = sqrt(dot(n,n))
	if(norm==0.0){ return n}
	return n/norm
}







