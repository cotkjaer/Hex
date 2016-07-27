//
//  ViewController.swift
//  HexDemo
//
//  Created by Christian Otkjær on 23/05/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit
import Hex
import Random

protocol HexMapViewControllerDelegate
{
    func hexMapController(controller: HexMapViewController, didSelectHex: Hex)
    func hexMapController(controller: HexMapViewController, didDeselectHex: Hex)
}

class HexMapViewController: HexesCollectionViewController
{
    var delegate : HexMapViewControllerDelegate?
    
    var map : HexMap<Bool> = HexMap()
        {
        didSet
        {
            for (hex, _) in map
            {
                map[hex] = Int.random(between: 0, and: 1000) > 400
            }

            hexes = Array(map.hexes)
            
            removePathLayers()
            
            for ip in collectionView?.indexPathsForSelectedItems() ?? []
            {
            collectionView?.deselectItemAtIndexPath(ip, animated: false)
            }
            
            updateLine()
        }
    }
    
    var moveCostMap : HexMap<Int>?
    
    override func viewDidLoad()
    {
        hexesLayout?.hexSpacing = 5
        hexesLayout?.hexEdgeLength = 35
        hexesLayout?.scrollDirection = .None
        
        super.viewDidLoad()
    }
    
    override func configureCell(cell: UICollectionViewCell, forHex hex: Hex)
    {
        if let cell = cell as? HexCollectionViewCell
        {
            
            if map[hex] == true
            {
                cell.backgroundColor = UIColor(white: 0.8, alpha: 1)
            }
            else
            {
                cell.backgroundColor = UIColor.darkGrayColor()
            }
            
            if cell.selected
            {
                cell.backgroundColor = UIColor.redColor()
            }
            
            let offset = hex.offsetCoordinates(orientation, offset: .Odd)
            
            cell.detailLabel?.text = "\(offset.col + 1)x\(offset.row + 1)"
            
            if let cost = moveCostMap?[hex]
            {
                cell.textLabel?.text = "\(cost)"
            }
            else
            {
                cell.textLabel?.text = nil
            }

            if hexLine.contains(hex)
            {
                cell.backgroundColor = cell.backgroundColor?.colorWithAlphaComponent(0.5)
                
                cell.borderColor = UIColor.orangeColor()
                cell.borderWidth = 10
            }
            else
            {
                cell.borderColor = UIColor.clearColor()
                cell.borderWidth = 0
            }
        }
    }
    
    var lastSelectedHex : Hex?
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        guard let hex = hexForIndexPath(indexPath) else { return }

        delegate?.hexMapController(self, didSelectHex: hex)

//        if let cell = collectionView.cellForItemAtIndexPath(indexPath)
//        {
//            configureCell(cell, forHex: hex)
//            
//            updateLine()
//        }
    }
    
    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath)
    {
        guard let hex = hexForIndexPath(indexPath) else { return }

        delegate?.hexMapController(self, didDeselectHex: hex)
        
//        if let c = collectionView.cellForItemAtIndexPath(indexPath)
//        {
//            configureCell(c, forHex: hex)
//            lastSelectedHex = hex
//            
//            updateLine()
//        }
    }
    
    var selectedIndexPath : NSIndexPath? { return collectionView?.indexPathsForSelectedItems()?.first }
    
    let lineLayer = CAShapeLayer()
    
    var hexLine : [Hex] = []

    func updateLine()
    {
        if let s = hexForIndexPath(selectedIndexPath)
        {
            //Movement
            
            func c(b: Bool?) -> Int?
            {
                return b == true ? 1 : nil
            }
            
            moveCostMap = map.moveCostForHex(s, movement: 10, costFunction: c)
            
            if let h = lastSelectedHex, let hexLayout = hexesLayout
            {
                hexLine = h.lineTo(s)
                
                let path = UIBezierPath()
                
                path.moveToPoint(hexLayout.centerForHex(h))
                path.addLineToPoint(hexLayout.centerForHex(s))
                
                lineLayer.path = path.CGPath
                lineLayer.strokeColor = UIColor.blackColor().colorWithAlphaComponent(0.5).CGColor
                lineLayer.lineWidth = hexLayout.hexEdgeLength / 3
                lineLayer.lineCap = kCALineCapRound
                
                collectionView?.layer.addSublayer(lineLayer)
                
                updatePaths(s, destination: h)
            }
            
            collectionView?.indexPathsForVisibleItems().forEach({ (indexPath) in
                if let hex = hexForIndexPath(indexPath), let cell = collectionView?.cellForItemAtIndexPath(indexPath)
                {
                    configureCell(cell, forHex: hex)
                }
            })
        }
    }
    
    func removePathLayers()
    {
        // remove pathLayers
        
        collectionView?.layer.sublayers?.filter({$0.name == "hexpath"}).forEach({$0.removeFromSuperlayer()})
    }
    
    func updatePaths(origin: Hex, destination: Hex)
    {
        removePathLayers()
        
        func c(b: Bool?) -> Int?
        {
            return b == true ? 1 : nil
        }
        
        let paths = map.pathsFrom(from: origin, to: destination, costFunction: c)
        
        for (node, dests) in paths?.nodes ?? [ : ]
        {
            for dest in dests
            {
                addLayerForLineFrom(node, h2: dest, color: UIColor.redColor())
            }
        }
    }

    func addLayerForLineFrom(h1: Hex, h2: Hex, color: UIColor)
    {
        if let hexLayout = hexesLayout
        {
            let path = UIBezierPath()
            
            let layer = CAShapeLayer()
            
            path.moveToPoint(hexLayout.centerForHex(h1))
            
            path.addLineToPoint(hexLayout.centerForHex(h2))
            
            layer.fillColor = nil
            layer.name = "hexpath"
            layer.path = path.CGPath
            layer.strokeColor = color.colorWithAlphaComponent(0.5).CGColor
            layer.lineWidth = hexLayout.hexEdgeLength / 4
            layer.lineCap = kCALineCapRound
            layer.lineJoin = kCALineJoinRound
            
            collectionView?.layer.addSublayer(layer)
        }
    }
    
    func updatePath(hexpath: [Hex], origin: Hex, layer: CAShapeLayer, color: UIColor)
    {
        if let hexLayout = hexesLayout
        {
            let path = UIBezierPath()
            
            path.moveToPoint(hexLayout.centerForHex(origin))
            
            collectionView?.layer.addSublayer(lineLayer)
            
            for hex in hexpath
            {
                path.addLineToPoint(hexLayout.centerForHex(hex))
            }
            
            layer.fillColor = nil
            layer.name = "hexpath"
            layer.path = path.CGPath
            layer.strokeColor = color.colorWithAlphaComponent(0.5).CGColor
            layer.lineWidth = hexLayout.hexEdgeLength / 3
            layer.lineCap = kCALineCapRound
            layer.lineJoin = kCALineJoinRound
            
            collectionView?.layer.addSublayer(layer)
        }
    }
}