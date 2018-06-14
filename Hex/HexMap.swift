//
//  HexMap.swift
//  Hex
//
//  Created by Christian Otkjær on 24/05/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import Foundation
//import Collections
import Heap

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

public struct HexMap<Element>
{
    fileprivate var dict = Dictionary<Hex, Element>()
    
    public init(dictionary: Dictionary<Hex, Element>)
    {
        self.dict = dictionary
    }
    
    public init()
    {
    }
    
    public init(shape: HexMapShape, initialValueBlock: (_ hex: Hex) -> Element)
    {
        for hex in shape.hexes
        {
            dict[hex] = initialValueBlock(hex)
        }
    }

    public init(shape: HexMapShape, repeatedValue: Element)
    {
        for hex in shape.hexes
        {
            dict[hex] = repeatedValue
        }
    }

    
//    public init<S : SequenceType where S.Generator.Element == Hex>(hexes : S, repeatedBlock: (hex: Hex) -> Element)
//    {
//        for hex in hexes
//        {
//            dict[hex] = repeatedBlock(hex: hex)
//        }
//    }
//    
//    
//    public init<S : SequenceType where S.Generator.Element == Hex>(hexes : S, repeatedValue: Element)
//    {
//        self.init(hexes: hexes, repeatedBlock: { _ in return repeatedValue })
//    }
    
//    public init(rhombusWithMinQ minQ: Int,
//                                maxQ: Int,
//                                minR: Int,
//                                maxR: Int,
//                                repeatedValue: Element)
//    {
//        for q in minQ...maxQ
//        {
//            for r in minR...maxR
//            {
//                dict[Hex(q,r)] = repeatedValue
//            }
//        }
//    }
//    
//    public init(triangleOfSize size: Int,
//                               repeatedValue: Element)
//    {
//        for q in 0...size
//        {
//            for r in 0...size - q
//            {
//                dict[Hex(q, r)] = repeatedValue
//            }
//        }
//    }
//    
//    public init(hexagonWithRadius radius: Int, repeatedBlock: (Hex) -> Element)
//    {
//        self.init(hexes: hexagonWithRadius(radius), repeatedBlock: repeatedBlock)
//    }
//    
//    public init(hexagonWithRadius radius: Int, repeatedValue: Element)
//    {
//        self.init(hexes: hexagonWithRadius(radius), repeatedValue: repeatedValue)
//    }
//    
//    public init(rectangleWithWidth width: Int, height: Int, repeatedValue: Element)
//    {
//        for r in 0 ..< height
//        {
//            let r_offset = r>>1
//            
//            for q in -r_offset ..< width - r_offset
//            {
//                dict[Hex(q,r)] = repeatedValue
//            }
//        }
//    }
//    
    public var isEmpty : Bool { return dict.isEmpty }
    
    public var hexes : [Hex] { return Array(dict.keys) }
    
    public func contains(_ hex: Hex) -> Bool
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

// MARK: - Sequence

extension HexMap: Sequence
{
    public typealias Iterator = DictionaryIterator<Hex, Element>
    
    public func makeIterator() -> DictionaryIterator<Hex, Element>
    {
        return dict.makeIterator()
    }
}

// MARK: - map

extension HexMap
{
    func map<T>(transform: (Element) throws -> T) rethrows -> HexMap<T>
    {
        return HexMap<T>(dictionary: try dict.map(transform: transform))
    }

    func compactMap<T>(transform: (Element) throws -> T?) rethrows -> HexMap<T>
    {
        return HexMap<T>(dictionary: try dict.compactMap(transform: transform))
    }
}

// MARK: - neighbor

extension HexMap
{
    public func neighborsToHex(_ hex: Hex) -> [Hex]
    {
        return hex.neighbors().filter { self[$0] != nil }
    }
    
    public func neighborValuesToHex(_ hex: Hex) -> [(Hex, Element)]
    {
        return hex.neighbors().filter { self[$0] != nil }.map { ($0, self[$0]!) }
    }
}

open class HexPaths
{
    var origin: Hex
    var destination: Hex
    
    open fileprivate(set) var nodes = [Hex: [Hex]]()
    
    internal init(from origin: Hex, to destination: Hex, in costToEnterMap: HexMap<Int>)
    {
        self.origin = origin
        self.destination = destination
        
        func mapHex(_ hex: Hex)
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

    fileprivate func count(_ hex: Hex) -> Int
    {
        if hex == destination { return 1 }
        
        var c = 0
        
        for neighbor in nodes[hex] ?? []
        {
           c += count(neighbor)
        }
        
        return c
    }
    
    open var count : Int { return count(origin) }

    open func iteratePaths(_ closure: @escaping ([Hex]) -> ())
    {
        func traverse(_ hex: Hex, pathSoFar: [Hex])
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
    @discardableResult
    public func moveCostForHex(_ start: Hex, movement: Int = Int.max, costFunction: (Element?) -> Int?) -> HexMap<Int>
    {
        var enterCostMap = self.compactMap( transform: costFunction )
        
        enterCostMap[start] = 0
        
        var fringe = BinaryHeap<(cost: Int, hex: Hex)>(isOrderedBefore: { $0.cost < $1.cost })
        
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

    public func pathsFrom(from origin: Hex, to destination: Hex, costFunction: (Element?) -> Int?) -> HexPaths?
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
    public func shortestPathFrom(from origin: Hex, to destination: Hex, costFunction: (Element?) -> Int?) -> [[Hex]]
    {
        guard contains(destination) else { return [] }
        
        guard origin != destination else { return [] }

        guard let best = moveCostForHex(origin, costFunction: costFunction)[destination] else { return [] }
        
        var paths : [[Hex]] = []

        var enterCostMap = self.compactMap( transform: costFunction )
        enterCostMap[origin] = 0
        
        var frontier = BinaryHeap<(cost: Int, hexes: [Hex])>(isOrderedBefore: {$0.cost < $1.cost} )
        
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
    public func hexesInRange(_ N: Int, fromHex hex: Hex) -> Array<Hex>
    {
        return hex.inRange(steps: N).filter { self[$0] != nil }
    }
}


// MARK: - Shapes

private func hexagonWithRadius(_ radius: Int) -> [Hex]
{
    var hexes : [Hex] = []
    
    for q in -radius...radius
    {
        let r1 = max(-radius, -q - radius)
        let r2 = min(radius, -q + radius)
        
        for r in r1...r2
        {
            hexes.append(Hex(q,r))
            
            //                dict[Hex(q,r)] = repeatedValue
        }
    }
    
    return hexes
}

private func rhombusWithMinQ(_ minQ: Int,
                             maxQ: Int,
                             minR: Int,
                             maxR: Int) -> [Hex]
{
    return (minQ...maxQ).flatMap { q in (minR...maxR).map { r in Hex(q,r) } }

//    var hexes : [Hex] = []
//
//    for q in minQ...maxQ
//    {
//        for r in minR...maxR
//        {
//            hexes.append(Hex(q,r))
//        }
//    }
//    
//    return hexes
}
