//
//  HexLayout.swift
//  Hex
//
//  Created by Christian Otkjær on 23/05/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import Foundation


struct HexLayout
{
    /// Orientation ; Horizontal or Vertical
    let orientation : HexOrientation
    
    /// The side-length for each hex
    let edgeLength : CGFloat
    
    /// The spacing between hexes
    let spacing : CGFloat

    /// Scale
    let scale : CGFloat
    
    /// Offset for all hex-centers
    let offset : CGPoint
    
    func centerForHex(hex h: Hex) -> CGPoint
    {
        let F = orientation.forwardMatrix
        
        let l = ( edgeLength + spacing * 0.5 ) * scale
        
        let c = h.coordinates
        
        let x = (F.0 * c.q + F.1 * c.r) * l
        let y = (F.2 * c.q + F.3 * c.r) * l
        
        return CGPoint(x: offset.x + x, y: offset.y + y)
    }
    
    func hex(_ point: CGPoint) -> Hex
    {
        let B = orientation.backwardMatrix
        
        let l = ( edgeLength + spacing * 0.5 ) * scale

        let p = CGPoint(x: (point.x - offset.x) / l,
                        y: (point.y - offset.y) / l)
        
        let q = B.0 * p.x + B.1 * p.y
        let r = B.2 * p.x + B.3 * p.y
        let s = -q - r
        
        // (q,r,s) may be a fractional Hex, as the point may not be at a hex center
        // return the rounded Hex to get the closest
        return Hex(q: q, r: r, s: s)
    }
    
    fileprivate func cornerOffset(_ corner : Int) -> CGPoint
    {
        let angle = π2 *
            (CGFloat(corner) + orientation.startAngle) / 6
        
        return CGPoint(x: edgeLength * scale * cos(angle),
                       y: edgeLength * scale * sin(angle))
    }
    
    // - note: HexPoint should be rounded
    func corners(hex h: Hex) -> [CGPoint]
    {
        let c = centerForHex(hex: h)
        
        return (0..<6).map {
            return c + cornerOffset($0)
        }
    }
}

// MARK: - Bounds

extension HexLayout
{
    func boundsForHex(_ hex: Hex) -> CGRect
    {
        return bounds(corners(hex: hex))
    }

    func boundsForHex(_ hex: Hex?) -> CGRect?
    {
        guard let hex = hex else { return nil }
        
        return boundsForHex(hex)
    }
    
    func boundsForHexes<S: Collection>(_ hexes: S) -> CGRect where S.Iterator.Element == Hex
    {
        guard !hexes.isEmpty else { return CGRect.zero }
        
        var b = boundsForHex(hexes.first!)
        
        for hex in hexes
        {
            b = b.union(boundsForHex(hex))
        }
        
        return b
    }
}


// MARK: - Equatable

extension HexLayout : Equatable {}

func == (lhs: HexLayout, rhs: HexLayout) -> Bool
{
    return lhs.orientation == rhs.orientation && lhs.edgeLength == rhs.edgeLength && lhs.spacing == rhs.spacing && lhs.scale == rhs.scale && lhs.offset == rhs.offset
}


