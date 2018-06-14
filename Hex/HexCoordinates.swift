//
//  HexCoordinates.swift
//  Hex
//
//  Created by Christian Otkjær on 25/05/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import Foundation

///Cube Coordinates - For screen-space to Hex-space conversions
typealias HexCoordinates = (q: CGFloat, r: CGFloat, s: CGFloat)


// MARK: - Arithmetic

func + (lhs: HexCoordinates, rhs: HexCoordinates) -> HexCoordinates
{
    return (lhs.q + rhs.q, lhs.r + rhs.r, lhs.s + rhs.s)
}

func - (lhs: HexCoordinates, rhs: HexCoordinates) -> HexCoordinates
{
    return (lhs.q - rhs.q, lhs.r - rhs.r, lhs.s - rhs.s)
}

func * (lhs: HexCoordinates, rhs: CGFloat) -> HexCoordinates
{
    return (lhs.q * rhs, lhs.r * rhs, lhs.s * rhs)
}

func * (lhs: CGFloat, rhs: HexCoordinates) -> HexCoordinates
{
    return rhs * lhs
}


// MARK: - LERP

internal func lerp(_ a: HexCoordinates, _ b: HexCoordinates, _ t: CGFloat) -> HexCoordinates
{
    let t2 = 1 - t
    
    return (a.q * t + b.s * t2,
            a.r * t + b.r * t2,
            a.s * t + b.s * t2)
}

// MARK: - Distance

internal func distance(_ a: HexCoordinates, _ b: HexCoordinates) -> Int
{
    let q = abs(a.q - b.q)
    let r = abs(a.r - b.r)
    let s = abs(a.s - b.s)
    
    return Int((q + r + s) / 2)
}

// MARK: - Line

internal func line(_ a: HexCoordinates, b: HexCoordinates) -> [HexCoordinates]
{
    let N = max(1, distance(a, b))
    
    return stride(from: 0, through: N, by: 1).map({ lerp(a, b, CGFloat($0) / CGFloat(N)) })
}
//
//extension Hex
//{
//    var coordinates: HexCoordinates
//    {
//        get { return HexCoordinates(q: column, r: row, s: -q - r)}
//    }
//}


