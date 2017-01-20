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
    func hexMapController(_ controller: HexMapViewController, didSelectHex: Hex)
    func hexMapController(_ controller: HexMapViewController, didDeselectHex: Hex)
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
            
            for ip in collectionView?.indexPathsForSelectedItems ?? []
            {
            collectionView?.deselectItem(at: ip, animated: false)
            }
            
            updateLine()
        }
    }
    
    var moveCostMap : HexMap<Int>?
    
    override func viewDidLoad()
    {
        hexesLayout?.hexSpacing = 5
        hexesLayout?.hexEdgeLength = 35
        hexesLayout?.scrollDirection = .none
        
        super.viewDidLoad()
    }
    
    override func configureCell(_ cell: UICollectionViewCell, forHex hex: Hex)
    {
        if let cell = cell as? HexCollectionViewCell
        {
            
            if map[hex] == true
            {
                cell.backgroundColor = UIColor(white: 0.8, alpha: 1)
            }
            else
            {
                cell.backgroundColor = UIColor.darkGray
            }
            
            if cell.isSelected
            {
                cell.backgroundColor = UIColor.red
            }
            
            let offset = hex.offsetCoordinates(orientation, offset: .odd)
            
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
                cell.backgroundColor = cell.backgroundColor?.withAlphaComponent(0.5)
                
                cell.borderColor = UIColor.orange
                cell.hexBorderWidth = 10
            }
            else
            {
                cell.borderColor = UIColor.clear
                cell.hexBorderWidth = 0
            }
        }
    }
    
    var lastSelectedHex : Hex?
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
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
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
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
    
    var selectedIndexPath : IndexPath? { return collectionView?.indexPathsForSelectedItems?.first }
    
    let lineLayer = CAShapeLayer()
    
    var hexLine : [Hex] = []

    func updateLine()
    {
        if let s = hexForIndexPath(selectedIndexPath)
        {
            //Movement
            
            func c(_ b: Bool?) -> Int?
            {
                return b == true ? 1 : nil
            }
            
            moveCostMap = map.moveCostForHex(s, movement: 10, costFunction: c)
            
            if let h = lastSelectedHex, let hexLayout = hexesLayout
            {
                hexLine = h.lineTo(s)
                
                let path = UIBezierPath()
                
                path.move(to: hexLayout.centerForHex(h))
                path.addLine(to: hexLayout.centerForHex(s))
                
                lineLayer.path = path.cgPath
                lineLayer.strokeColor = UIColor.black.withAlphaComponent(0.5).cgColor
                lineLayer.lineWidth = hexLayout.hexEdgeLength / 3
                lineLayer.lineCap = kCALineCapRound
                
                collectionView?.layer.addSublayer(lineLayer)
                
                updatePaths(s, destination: h)
            }
            
            collectionView?.indexPathsForVisibleItems.forEach({ (indexPath) in
                if let hex = hexForIndexPath(indexPath), let cell = collectionView?.cellForItem(at: indexPath)
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
    
    func updatePaths(_ origin: Hex, destination: Hex)
    {
        removePathLayers()
        
        func c(_ b: Bool?) -> Int?
        {
            return b == true ? 1 : nil
        }
        
        let paths = map.pathsFrom(from: origin, to: destination, costFunction: c)
        
        for (node, dests) in paths?.nodes ?? [ : ]
        {
            for dest in dests
            {
                addLayerForLineFrom(node, h2: dest, color: UIColor.red)
            }
        }
    }

    func addLayerForLineFrom(_ h1: Hex, h2: Hex, color: UIColor)
    {
        if let hexLayout = hexesLayout
        {
            let path = UIBezierPath()
            
            let layer = CAShapeLayer()
            
            path.move(to: hexLayout.centerForHex(h1))
            
            path.addLine(to: hexLayout.centerForHex(h2))
            
            layer.fillColor = nil
            layer.name = "hexpath"
            layer.path = path.cgPath
            layer.strokeColor = color.withAlphaComponent(0.5).cgColor
            layer.lineWidth = hexLayout.hexEdgeLength / 4
            layer.lineCap = kCALineCapRound
            layer.lineJoin = kCALineJoinRound
            
            collectionView?.layer.addSublayer(layer)
        }
    }
    
    func updatePath(_ hexpath: [Hex], origin: Hex, layer: CAShapeLayer, color: UIColor)
    {
        if let hexLayout = hexesLayout
        {
            let path = UIBezierPath()
            
            path.move(to: hexLayout.centerForHex(origin))
            
            collectionView?.layer.addSublayer(lineLayer)
            
            for hex in hexpath
            {
                path.addLine(to: hexLayout.centerForHex(hex))
            }
            
            layer.fillColor = nil
            layer.name = "hexpath"
            layer.path = path.cgPath
            layer.strokeColor = color.withAlphaComponent(0.5).cgColor
            layer.lineWidth = hexLayout.hexEdgeLength / 3
            layer.lineCap = kCALineCapRound
            layer.lineJoin = kCALineJoinRound
            
            collectionView?.layer.addSublayer(layer)
        }
    }
}
