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

func bounds<S: Collection>(_ points :S) -> CGRect where S.Iterator.Element == CGPoint
{
    guard let first = points.first else { return CGRect.zero }
    
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

func bounds<S: Collection>(_ rects :S) -> CGRect where S.Iterator.Element == CGRect
{
    guard let first = rects.first else { return CGRect.zero }
    
    return rects.reduce(first, { $0.union($1) })
}

func closedPath<S: Sequence>(_ points :S) -> UIBezierPath where S.Iterator.Element == CGPoint
{
    let path = UIBezierPath()
    
    for point in points
    {
        if path.isEmpty
        {
            path.move(to: point)
        }
        else
        {
            path.addLine(to: point)
        }
    }
    
    path.close()
    
    return path
}

