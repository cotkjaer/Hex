//
//  HexLayer.swift
//  Hex
//
//  Created by Christian Otkjær on 29/09/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import Foundation

class HexLayer: CAShapeLayer
{
    open var orientation : HexOrientation = DefaultHexOrientation
        {
        didSet { update(oldValue != orientation) }
    }
    
    open override var bounds: CGRect
        {
        didSet {  update(oldValue != bounds) }
    }
    
    open override var frame: CGRect
        {
        didSet { update(oldValue != frame) }
    }

    func update(_ doUpdate: Bool = true)
    {
        guard doUpdate else { return }
        
        let center = bounds.center
        
        let width = bounds.width / orientation.hexWidth
        let height = bounds.height / orientation.hexHeight
        
        let edgeLength = min(width, height)
        
        func cornerOffset(_ corner : Int) -> CGPoint
        {
            let angle = π2 *
                (CGFloat(corner) + orientation.startAngle) / 6
            
            return CGPoint(x: edgeLength * cos(angle),
                           y: edgeLength * sin(angle))
        }
        
        func corners() -> [CGPoint]
        {
            return (0..<6).map {
                return center + cornerOffset($0)
            }
        }
        
        func pathForHex() -> CGPath
        {
            let points = corners()
            
            let path = closedPath(points)
            
            return path.cgPath
        }
        
        path = pathForHex()

        setNeedsDisplay()
    }
}
