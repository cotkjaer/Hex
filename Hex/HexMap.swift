//
//  HexMap.swift
//  Hex
//
//  Created by Christian Otkjær on 24/05/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import Foundation
import Collections

public struct HexMap<Element>
{
    private var dict = Dictionary<Hex, Element>()
    
    public init(dictionary: Dictionary<Hex, Element>)
    {
        self.dict = dictionary
    }
    
    public init()
    {
    }
    
    public init<S : SequenceType where S.Generator.Element == Hex>(hexes : S, repeatedValue: Element)
    {
        for hex in hexes
        {
            dict[hex] = repeatedValue
        }
    }
    
    public init(rhombusWithMinQ minQ: Int,
                                maxQ: Int,
                                minR: Int,
                                maxR: Int,
                                repeatedValue: Element)
    {
        for q in minQ...maxQ
        {
            for r in minR...maxR
            {
                dict[Hex(q,r)] = repeatedValue
            }
        }
    }
    
    public init(triangleOfSize size: Int,
                               repeatedValue: Element)
    {
        for q in 0...size
        {
            for r in 0...size - q
            {
                dict[Hex(q, r)] = repeatedValue
            }
        }
    }
    
    public init(hexagonWithRadius radius: Int, repeatedValue: Element)
    {
        for q in -radius...radius
        {
            let r1 = max(-radius, -q - radius)
            let r2 = min(radius, -q + radius)
            
            for r in r1...r2
            {
                dict[Hex(q,r)] = repeatedValue
            }
        }
    }
    
    public init(rectangleWithWidth width: Int, height: Int, repeatedValue: Element)
    {
        for r in 0 ..< height
        {
            let r_offset = r>>1
            
            for q in -r_offset ..< width - r_offset
            {
                dict[Hex(q,r)] = repeatedValue
            }
        }
    }
    
    public var isEmpty : Bool { return dict.isEmpty }
    
    public var hexes : [Hex] { return Array(dict.keys) }
    
    public func contains(hex: Hex) -> Bool
    {
        return dict[hex] != nil
    }
}

// MARK: - Subscript

extension HexMap
{
    public typealias Index = Dictionary<Hex, Element>.Index
    
    public var startIndex: Index
    {
        return dict.startIndex
    }
    
    public var endIndex: Index
    {
        return dict.endIndex
    }
    
    /// Accesses the element at index `hex`
    public subscript(hex: Hex) -> Element?
        {
        get { return dict[hex] }
        set { dict[hex] = newValue }
    }

    /// Subscript for axial coordinates
    public subscript(column: Int, row: Int) -> Element?
    {
        get { return self[Hex(column, row)] }
        set { self[Hex(column, row)] = newValue }
    }
    
    public var first: (Hex, Element)? { return dict.first }
}

// MARK: - SequenceType

extension HexMap: SequenceType
{
    public func generate() -> DictionaryGenerator<Hex, Element>
    {
        return dict.generate()
    }
}

// MARK: - map

extension HexMap
{
    @warn_unused_result
    func map<T>(@noescape transform: Element throws -> T) rethrows -> HexMap<T>
    {
        return HexMap<T>(dictionary: try dict.map(transform))
    }

    @warn_unused_result
    func flatMap<T>(@noescape transform: Element throws -> T?) rethrows -> HexMap<T>
    {
        return HexMap<T>(dictionary: try dict.flatMap(transform))
    }
}

// MARK: - neighbor

extension HexMap
{
    func neighborsToHex(hex: Hex) -> [Hex]
    {
        return hex.neighbors().filter { self[$0] != nil }
    }
    
    func neighborValuesToHex(hex: Hex) -> [(Hex, Element)]
    {
        return hex.neighbors().filter { self[$0] != nil }.map { ($0, self[$0]!) }
    }
}

public class HexPaths
{
    var origin: Hex
    var destination: Hex
    
    public private(set) var nodes = [Hex: [Hex]]()
    
    internal init(from origin: Hex, to destination: Hex, in costToEnterMap: HexMap<Int>)
    {
        self.origin = origin
        self.destination = destination
        
        func mapHex(hex: Hex)
        {
            if nodes[hex] == nil
            {
                let neighbors = costToEnterMap.neighborsToHex(hex).filter { costToEnterMap[$0] < costToEnterMap[hex] }
                
                nodes[hex] = neighbors
                
                neighbors.forEach { mapHex($0)}
            }
        }
        
        mapHex(origin)

    }

    private func count(hex: Hex) -> Int
    {
        if hex == destination { return 1 }
        
        var c = 0
        
        for neighbor in nodes[hex] ?? []
        {
           c += count(neighbor)
        }
        
        return c
    }
    
    public var count : Int { return count(origin) }

    public func iteratePaths(closure: [Hex] -> ())
    {
        func traverse(hex: Hex, pathSoFar: [Hex])
        {
            let hexes = pathSoFar + [hex]

            if hex == destination { closure(hexes); return }

            for neighbor in nodes[hex] ?? []
            {
                traverse(neighbor, pathSoFar: hexes)
            }
        }
        
        traverse(origin, pathSoFar: [])
    }
}

// MARK: - Move Map

extension HexMap
{
    /// Make a map of the cost of moving from `start` and a maximum of `movement` steps.
    public func moveCostForHex(start: Hex, movement: Int = Int.max, costFunction: Element? -> Int?) -> HexMap<Int>
    {
        var enterCostMap = self.flatMap( costFunction )
        
        enterCostMap[start] = 0
        
        var fringe = Heap<(cost: Int, hex: Hex)>(isOrderedBefore: { $0.cost < $1.cost })
        
        fringe.push((0, start))
        
        var costMap = HexMap<Int>(dictionary: [start: 0])

        while let (cost, hex) = fringe.pop()
        {
            for (neighbor, enterCost) in enterCostMap.neighborValuesToHex(hex)
            {
                if costMap[neighbor] == nil
                {
                    costMap[neighbor] = enterCost + cost
                    fringe.push((enterCost + cost, neighbor))
                }
            }
        }
        
        return costMap
    }

    public func pathsFrom(from origin: Hex, to destination: Hex, costFunction: Element? -> Int?) -> HexPaths?
    {
        guard contains(origin) else { return nil }
        
        guard contains(destination) else { return nil }
        
        guard origin != destination else { return nil }
        
        let moveCost = moveCostForHex(destination, costFunction: costFunction)
        
        guard moveCost.contains(origin) else { return nil }
        
        return HexPaths(from: origin, to: destination, in: moveCost)
    }
    
    /*
    public func shortestPathsFrom(from origin: Hex, to destination: Hex, costFunction: Element? -> Int?) -> [[Hex]]
    {
        guard contains(origin) else { return [] }
        
        guard contains(destination) else { return [] }
        
        guard origin != destination else { return [] }
        
        let moveCost = moveCostForHex(destination, costFunction: costFunction)
        
        guard moveCost.contains(origin) else { return [] }
        
        func shortestPathsFrom(hex: Hex) -> [[Hex]]
        {
            if hex == destination { return [[]] }
            
            let neighbors = moveCost.neighborsToHex(hex).filter({ moveCost[$0] < moveCost[hex] })
            
            var paths = [[Hex]]()
            
            for neighbor in neighbors
            {
                for p in shortestPathsFrom(neighbor)
                {
                    paths.append([neighbor] + p)
                }
            }
            
            return paths
        }

        return shortestPathsFrom(origin)
    }
 */

    
    
    /// Find the shortest paths from one hex to another using a breadth first search
    ///
    /// - parameter from: The starting hex.
    /// - parameter to: The destination hex.
    /// - returns: The shortest path(s) from origin to destination, if none could be found an empty array is returned
    public func shortestPathFrom(from origin: Hex, to destination: Hex, costFunction: Element? -> Int?) -> [[Hex]]
    {
        guard contains(destination) else { return [] }
        
        guard origin != destination else { return [] }

        guard let best = moveCostForHex(origin, costFunction: costFunction)[destination] else { return [] }
        
        var paths : [[Hex]] = []

        var enterCostMap = self.flatMap( costFunction )
        enterCostMap[origin] = 0
        
        var frontier: Heap<(cost: Int, hexes: [Hex])> = Heap(isOrderedBefore: {$0.cost < $1.cost})
        
        for neighbor in neighborsToHex(origin)
        {
            if let costToEnter = enterCostMap[neighbor]
            {
                frontier.push((costToEnter, [neighbor]))
            }
        }
        
        // Get the shortest path in the frontier
        while let path = frontier.pop()
        {
            if path.cost > best { continue }
            
            if let hex = path.hexes.last
            {
                if hex == destination
                {
                    paths.append(path.hexes)
                }
                else
                {
                    for neighbor in neighborsToHex(hex).filter({ !path.hexes.contains($0) })
                    {
                        if let costToEnter = enterCostMap[neighbor]
                        {
                            frontier.push((cost: path.cost + costToEnter, hexes: path.hexes + [neighbor]))
                        }
                    }
                }
            }
        }
        
        return paths
    }
}


// MARK: - Range

extension HexMap
{
    ///Given a hex and a range N, which hexes are within N steps from it?
    public func hexesInRange(N: Int, fromHex hex: Hex) -> Array<Hex>
    {
        return hex.inRange(steps: N).filter { self[$0] != nil }
    }
}

