//
//  ShapeViewController.swift
//  Hex
//
//  Created by Christian Otkjær on 21/07/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit
import Hex
import Collections

class ShapeViewController: UIViewController
{
    var shape : HexMapShape = .custom(hexes: [])
        {
            didSet
            {
                childHexMapViewController?.map = HexMap<Bool>(shape: shape, repeatedValue: true)
                
//                childHexMapViewController?.hexes = shape.hexes
        }
    }

    override func addChildViewController(_ childController: UIViewController)
    {
        super.addChildViewController(childController)
        
        guard let hexMapViewController = childController as? HexMapViewController else { return }
        
        hexMapViewController.delegate = self
    }
    
    var childHexMapViewController : HexMapViewController?
    {
        return childViewControllers.find(HexMapViewController.self)
    }
}

// MARK: - HexMapViewControllerDelegate

extension ShapeViewController : HexMapViewControllerDelegate
{
    func hexMapController(_ controller: HexMapViewController, didSelectHex hex: Hex)
    {
        controller.reloadCellForHex(hex)
        controller.updateLine()
    }
    
    func hexMapController(_ controller: HexMapViewController, didDeselectHex hex: Hex)
    {
        controller.reloadCellForHex(hex)
        controller.lastSelectedHex = hex

        controller.updateLine()
        
    }
}

