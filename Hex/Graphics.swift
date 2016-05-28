//
//  Graphics.swift
//  Hex
//
//  Created by Christian Otkjær on 23/05/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import CoreGraphics

let π2 = CGFloat(M_PI * 2)

let sqrt3 : CGFloat = sqrt(3.0)
let sqrt3_2 : CGFloat = sqrt3 / 2
let sqrt3_3 : CGFloat = sqrt3 / 3


func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint
{
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

// MARK: - center

extension CGRect
{
    var center: CGPoint { return CGPoint(x: midX, y: midY) }
}


// MARK: - Bounds

func bounds<S: CollectionType where S.Generator.Element == CGPoint>(points :S) -> CGRect
{
    guard let first = points.first else { return CGRectZero }
    
    var (minX, maxX, minY, maxY) = (first.x, first.x, first.y, first.y)
    
    for point in points
    {
        minX = min(point.x, minX)
        minY = min(point.y, minY)
        
        maxX = max(point.x, maxX)
        maxY = max(point.y, maxY)
    }

    return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
}

func bounds<S: CollectionType where S.Generator.Element == CGRect>(rects :S) -> CGRect
{
    guard let first = rects.first else { return CGRectZero }
    
    return rects.reduce(first, combine: { $0.union($1) })
}

func closedPath<S: CollectionType where S.Generator.Element == CGPoint>(points :S) -> UIBezierPath
{
    let path = UIBezierPath()
    
    guard let first = points.first else { return path }
    
    path.moveToPoint(first)
    
    let startIndex = points.startIndex.advancedBy(1)
    
    for index in startIndex..<points.endIndex
    {
        path.addLineToPoint(points[index])
    }
    
    path.closePath()
    
    return path
}

