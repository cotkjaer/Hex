//
//  Hex.swift
//  Hex
//
//  Created by Christian Otkjær on 25/05/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import Foundation

public let HexZero = Hex(0, 0)

//Axial Index
public struct Hex : Hashable
{
    public let column, row : Int
    
    
    public init(_ q: Int, _ r: Int)
    {
        column = q
        row = r
        
        self.hashValue = column * 3011 &+ row
    }

    public init(_ q: Int, _ r: Int, _ s: Int)
    {
        assert(q + r + s == 0)
     
        self.init(q, r)
    }
    
    
    
    // MARK: - Hashable
    
    public let hashValue: Int
}

// MARK: - Equatable

extension Hex : Equatable {}

public func == (lhs: Hex, rhs: Hex) -> Bool
{
    return lhs.column == rhs.column && lhs.row == rhs.row
}

// MARK: - CustomDebugStringConvertible

extension Hex : CustomDebugStringConvertible
{
    public var debugDescription : String { return "\(column)x\(row)" }
}

// MARK: - CustomDebugStringConvertible

extension Hex : CustomStringConvertible
{
    public var description : String { return "\(column)x\(row)" }
}

// MARK: - Arithmetic

public func + (lhs: Hex, rhs: Hex) -> Hex
{
    return Hex(lhs.column + rhs.column, lhs.row + rhs.row)
}

public func - (lhs: Hex, rhs: Hex) -> Hex
{
    return Hex(lhs.column - rhs.column, lhs.row - rhs.row)
}

public func * (lhs: Hex, rhs: Int) -> Hex
{
    return Hex(lhs.column * rhs, lhs.row * rhs)
}

// MARK: - Neighbors

private let hex_neighbor_directions = [
    Hex(1, 0, -1), Hex(1, -1, 0), Hex(0, -1, 1),
    Hex(-1, 0, 1), Hex(-1, 1, 0), Hex(0, 1, -1)
]

private let hex_diagonal_neighbor_directions = [
    Hex(+2, -1, -1), Hex(+1, +1, -2), Hex(-1, +2, -1),
    Hex(-2, +1, +1), Hex(-1, -1, +2), Hex(+1, -2, +1)
]

private let directions = Array(0..<6)

extension Hex
{
    public func neighbor(direction: Int) -> Hex
    {
        assert(direction < 6 && direction >= 0)
        
        return hex_neighbor_directions[direction] + self
    }
    
    public func neighbors() -> [Hex]
    {
        return directions.map { neighbor($0) }
    }
    
    public func diagonalNeighbor(direction: Int, distance: Int = 1) -> Hex
    {
        assert(direction < 6 && direction >= 0)
        
        return self + ( hex_diagonal_neighbor_directions[direction] * distance )
    }
    
    public func diagonalNeighbors(distance : Int = 1) -> [Hex]
    {
        return directions.map { diagonalNeighbor($0, distance: distance)  }
    }
}

// MARK: - Coordinates

extension Hex
{
    /// Initializes the index by rounding the coordinates 
    internal init(_ c: HexCoordinates)
    {
        var q = round(c.0)
        var r = round(c.1)
        let s = round(c.2)
        
        let q_diff = abs(q - c.0)
        let r_diff = abs(r - c.1)
        let s_diff = abs(s - c.2)
        
        if (q_diff > r_diff && q_diff > s_diff)
        {
            q = round(-r - s)
        }
        else if (r_diff > s_diff)
        {
            r = round(-q - s)
        }
        
        self.init(Int(q),Int(r))
    }
    
    internal var coordinates : HexCoordinates { return HexCoordinates(q: CGFloat(column), r: CGFloat(row), s: CGFloat(-column - row)) }
}

// MARK: - Distance

public func distance(a: Hex, _ b: Hex) -> Int
{
    let d = a - b
    
    return (abs(d.column) + abs(d.row) + abs(-d.column - d.row)) / 2
}

extension Hex
{
    public func distanceTo(hex: Hex) -> Int
    {
        return distance(self, hex)
    }
}

// MARK: - Line

public func line(a: Hex, _ b: Hex) -> [Hex]
{
    return line(a.coordinates, b: b.coordinates).map { Hex($0) }
}

extension Hex
{
    public func lineTo(hex: Hex) -> [Hex]
    {
        return line(self, hex)
    }
}
// MARK: - Range

extension Hex
{
    ///Given a hex center and a range N, which hexes are within N steps from it?
    public func inRange(steps N: Int) -> [Hex]
    {
        var result = Array<Hex>()
        
        for dq in -N...N
        {
            for dr in max(-N, -dq - N)...min(N, -dq + N)
            {
                result.append(Hex(dq, dr) + self)
            }
        }
        
        return result
    }
}


// MARK: - Offset Coordinates

public enum OffsetType : Int
{
    case Odd = -1
    case Even = 1
}

extension Hex
{
    init(offsetCoordinates h: (row: Int, col: Int), orientation: HexOrientation, offset: OffsetType)
    {
        let column, row : Int
        switch orientation
        {
        case .Vertical:
            column = h.col
            row = h.row - Int((h.col + offset.rawValue * (h.col & 1)) / 2)
            
            
        case .Horizontal:
            column = h.col - Int((h.row + offset.rawValue * (h.row & 1)) / 2)
            row = h.row
        }
        
        self.init(column, row)
    }
    
    public func offsetCoordinates(orientation: HexOrientation, offset: OffsetType) -> (row: Int, col: Int)
    {
        switch orientation
        {
        case .Vertical:
            
            return (column, row + (column + offset.rawValue * (column & 1)) / 2)
            
        case .Horizontal:
            
            return (column + (row + offset.rawValue * (row & 1)) / 2, row)
        }
    }
}

