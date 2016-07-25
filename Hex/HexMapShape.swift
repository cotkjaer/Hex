//
//  HexMapShape.swift
//  Hex
//
//  Created by Christian Otkjær on 22/07/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import Foundation


public enum HexMapShape
{
    case Rectangle(width: Int, height: Int)
    case Hexagon(radius: Int)
    case Triangle(size: Int)
    case Rhombus(columns: Int, rows: Int)
//    case Rhombus(minQ: Int, maxQ: Int, minR: Int,        maxR: Int)
    case Custom(hexes: [Hex])
    
    public var hexes : [Hex]
    {
        var hs = [Hex]()
        
        switch self
        {
        case let .Rectangle(width, height):
            
            for r in 0 ..< height
            {
                let r_offset = r>>1
                
                for q in -r_offset ..< width - r_offset
                {
                    hs.append(Hex(q,r))
                }
            }
            
        case let .Hexagon(radius):
            
            return (-radius...radius).flatMap { q in (max(-radius, -q - radius)...min(radius, -q + radius)).map { r in Hex(q,r) } }
           
        case let .Rhombus(columns, rows):
//        case let .Rhombus(minQ, maxQ, minR, maxR):
            let minQ = 0
            let maxQ = columns
            
            let minR = 0
            let maxR = rows
            
            return (minQ...maxQ).flatMap { q in (minR...maxR).map { r in Hex(q,r) } }
            
        case let .Triangle(size):
            
            return (0...size).flatMap { q in (0...size - q).map { r in Hex(q,r) } }
            
        case let .Custom(hexes):
            
            return hexes
        }
        
        return hs
    }
}
