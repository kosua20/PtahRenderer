//
//  GeometricTypes.swift
//  PtahRenderer
//
//  Created by Simon Rodriguez on 14/02/2016.
//  Copyright © 2016 Simon Rodriguez. All rights reserved.
//

import Foundation

typealias Point3f = (Scalar, Scalar, Scalar)
typealias Point2f = (Scalar, Scalar)
typealias Point2i = (Int, Int)
typealias Vertex = Point3f
typealias Normal = Point3f
typealias UV = Point2f



/*--Point2i--------*/

func +(lhs : Point2i, rhs : Point2i) -> Point2i {
	return (lhs.0 + rhs.0,lhs.1+rhs.1)
}

func +=(inout lhs : Point2i, rhs : Point2i) {
	lhs.0 += rhs.0
	lhs.1 += rhs.1
}

func -(lhs : Point2i, rhs : Point2i) -> Point2i {
	return (lhs.0 - rhs.0,lhs.1-rhs.1)
}

func -=(inout lhs : Point2i, rhs : Point2i) {
	lhs.0 -= rhs.0
	lhs.1 -= rhs.1
}



/*--Point3f--------*/

func +(lhs : Point3f, rhs : Point3f) -> Point3f {
	return (lhs.0 + rhs.0,lhs.1+rhs.1,lhs.2+rhs.2)
}

func +=(inout lhs : Point3f, rhs : Point3f) {
	lhs.0 += rhs.0
	lhs.1 += rhs.1
	lhs.2 += rhs.2
}

func -(lhs : Point3f, rhs : Point3f) -> Point3f {
	return (lhs.0 - rhs.0,lhs.1-rhs.1,lhs.2-rhs.2)
}

func -=(inout lhs : Point3f, rhs : Point3f) {
	lhs.0 -= rhs.0
	lhs.1 -= rhs.1
	lhs.2 -= rhs.2
}

func *(lhs : Scalar, rhs : Point3f) -> Point3f {
	return (lhs*rhs.0,lhs*rhs.1,lhs*rhs.2)
}

func *(rhs : Point3f, lhs : Scalar) -> Point3f {
	return (lhs*rhs.0,lhs*rhs.1,lhs*rhs.2)
}

func *=(inout lhs : Point3f, rhs : Scalar){
	lhs.0 = lhs.0*rhs
	lhs.1 = lhs.1*rhs
	lhs.2 = lhs.2*rhs
}

func /(rhs : Point3f, lhs : Scalar) -> Point3f {
	return (rhs.0/lhs,rhs.1/lhs,rhs.2/lhs)
}

func /=(inout lhs : Point3f, rhs : Scalar){
	lhs.0 = lhs.0/rhs
	lhs.1 = lhs.1/rhs
	lhs.2 = lhs.2/rhs
}


func cross(lhs : Point3f,_ rhs : Point3f) -> Point3f {
	return (lhs.1*rhs.2 - lhs.2*rhs.1,lhs.2*rhs.0 - lhs.0*rhs.2,lhs.0*rhs.1 - lhs.1*rhs.0)
}

func dot(lhs : Point3f, _ rhs : Point3f) -> Scalar {
	return lhs.0*rhs.0+lhs.1*rhs.1+lhs.2*rhs.2
}

func norm(lhs : Point3f) -> Scalar {
	return sqrt(dot(lhs,lhs))
}

func norm2(lhs : Point3f) -> Scalar {
	return dot(lhs,lhs)
}

func normalize(inout n : Point3f){
	let norm = sqrt(dot(n,n))
	if(norm==0.0){ return }
	n /= norm
}

func normalized(n : Point3f) -> Point3f {
	let norm = sqrt(dot(n,n))
	if(norm==0.0){ return n}
	return n/norm
}







