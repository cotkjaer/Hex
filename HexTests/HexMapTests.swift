//
//  HexMapTests.swift
//  Hex
//
//  Created by Christian Otkjær on 24/05/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import XCTest

@testable import Hex

class HexMapTests: XCTestCase
{
    func test_time_to_init_HexMap()
    {
        measure
            {
                let _ = HexMap(rectangleWithWidth: 70, height: 60, repeatedValue: true)
        }
    }
    
    func test_iteration_for_HexMap()
    {
        let m1 = HexMap(rectangleWithWidth: 50, height: 40, repeatedValue: true)
        
        let m2 = HexMap(rectangleWithWidth: 50, height: 40, repeatedValue: true)

        var a1 = [Hex]()
        var a2 = [Hex]()
        
        for h in m1
        {
            a1.append(h.0)
        }
        
        for h in m2
        {
            a2.append(h.0)
        }
        
        XCTAssertEqual(a1, a2)
        XCTAssertEqual(a1.count, 50 * 40)
    }
    
    func test_moveCost()
    {
        let m = HexMap(rectangleWithWidth: 5, height: 5, repeatedValue: true)
        
        let start = Hex(0,0)
        
        m.moveCostForHex(start) {
            $0 == true ? 1 : nil
        }
        
        let mc = m.moveCostForHex(start, costFunction: { _ in 1 })
        
        XCTAssertEqual(mc[start], 0)
        
        let neighbors = m.neighborsToHex(start)
        
        for neighbor in neighbors
        {
            XCTAssertEqual(mc[neighbor], 1)
        }
    }
    
    func test_ShortestPath()
    {
        let m = HexMap(hexagonWithRadius: 15, repeatedValue: true)
        
        let origin = Hex(0,0)

        XCTAssert(m.contains(origin), "\(origin) not in map")

        for destination in origin.diagonalNeighbors()
        {
            XCTAssert(m.contains(destination), "\(destination) not in map")
            
            let paths = m.pathsFrom(from: origin, to: destination, costFunction: { $0 == true ? 1 : nil })
            
            XCTAssertNotNil(paths)
            
            XCTAssertEqual(paths!.count, 2)
        }
    }
}
