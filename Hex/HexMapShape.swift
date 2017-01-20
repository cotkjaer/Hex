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
    case rectangle(width: Int, height: Int)
    case hexagon(radius: Int)
    case triangle(size: Int)
    case rhombus(columns: Int, rows: Int)
//    case Rhombus(minQ: Int, maxQ: Int, minR: Int,        maxR: Int)
    case custom(hexes: [Hex])
    
    public var hexes : [Hex]
    {
        var hs = [Hex]()
        
        switch self
        {
        case let .rectangle(width, height):
            
            for r in 0 ..< height
            {
                let r_offset = r>>1
                
                for q in -r_offset ..< width - r_offset
                {
                    hs.append(Hex(q,r))
                }
            }
            
        case let .hexagon(radius):
            
            return (-radius...radius).flatMap { q in (max(-radius, -q - radius)...min(radius, -q + radius)).map { r in Hex(q,r) } }
           
        case let .rhombus(columns, rows):
//        case let .Rhombus(minQ, maxQ, minR, maxR):
            let minQ = 0
            let maxQ = columns
            
            let minR = 0
            let maxR = rows
            
            return (minQ...maxQ).flatMap { q in (minR...maxR).map { r in Hex(q,r) } }
            
        case let .triangle(size):
            
            return (0...size).flatMap { q in (0...size - q).map { r in Hex(q,r) } }
            
        case let .custom(hexes):
            
            return hexes
        }
        
        return hs
    }
}
