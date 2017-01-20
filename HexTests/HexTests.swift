//
//  HexTests.swift
//  HexTests
//
//  Created by Christian Otkjær on 20/05/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import XCTest
import Random
@testable import Hex

class HexTests: XCTestCase
{
    func test_init_Hex()
    {
        let hex = Hex(3, -2)
        
        XCTAssertEqual(hex.column, 3)
        XCTAssertEqual(hex.row, -2)
        
        XCTAssertEqual(hex.coordinates.s, -1)
    }
    
    func test_time_to_initialize()
    {
        measure
            {
                var _ = HexMap<Bool>(rectangleWithWidth: 20, height: 70, repeatedValue: true)
        }
    }
    
    func test_moveCost()
    {
        let radius = 1
        
        let map = HexMap(hexagonWithRadius: radius, repeatedValue: true)
        
        let hex = Hex(0, 0)
        
        let costMap = map.moveCostForHex(hex, costFunction: { _ in 1 })
        
        for (_, cost) in costMap
        {
            XCTAssertGreaterThanOrEqual(cost, 0)
        }
    }
    
    func test_moveCost_performance()
    {
        var map = HexMap<Bool>(rectangleWithWidth: 20, height: 70, repeatedValue: true)
        
        for (hex, _) in map
        {
            map[hex] = Int.random(between: 0, and: 1000) > 200
        }
        
        let hex : Hex = HexZero
        
        measure
            {
                let _ = map.moveCostForHex(hex, costFunction: { _ in 1 })
        }
    }
    
    func test_neighbors()
    {
        let h = HexZero
        
        XCTAssertEqual(h.neighbors().count, 6)
    }
    
    func test_distance()
    {
        let h = Hex(0, 0)
        
        for n in h.neighbors()
        {
            XCTAssertEqual(h.distanceTo(n), 1)
        }
        
        for n in h.diagonalNeighbors()
        {
            XCTAssertEqual(h.distanceTo(n), 2)
        }
        
    }
}
