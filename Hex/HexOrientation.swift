//
//  HexOrientation.swift
//  Hex
//
//  Created by Christian Otkjær on 23/05/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

public enum HexOrientation
{
    case vertical // flat top
    case horizontal // pointy top
}


extension HexOrientation
{
    // MARK: - Forward matrix; conversion from hex to carthesian coordinates
    var forwardMatrix : (CGFloat,CGFloat,CGFloat,CGFloat)
        {
        switch self
        {
        case .horizontal:
            return (sqrt(3), sqrt(3) / 2, 0, 3/2)
        case .vertical:
            return (3/2, 0, sqrt(3)/2, sqrt(3))
        }
    }
}


extension HexOrientation
{
    // MARK: - Backward matrix; conversion from carthesian coordinates to hex
    var backwardMatrix : (CGFloat,CGFloat,CGFloat,CGFloat)
    {
        switch self
        {
        case .horizontal:
            return (sqrt(3) / 3, -1/3, 0, 2/3)
        case .vertical:
            return (2/3, 0,-1/3, sqrt(3)/3)
        }
    }
}

// MARK: - vertex start angle

extension HexOrientation
{
    // MARK: - vertex start angle (in 60 degrees fractions)
    var startAngle : CGFloat
    {
        switch self
        {
        case .horizontal:
            return 0.5
        case .vertical:
            return 0
        }
    }
}

// MARK: - Size

extension HexOrientation
{
    var hexWidth : CGFloat
    {
        switch self
        {
        case .horizontal:
            return sqrt3
        case .vertical:
            return 2
        }
    }
    
    var hexHeight : CGFloat
    {
        switch self
        {
        case .horizontal:
            return 2
            
        case .vertical:
            return sqrt3
        }
    }
}
