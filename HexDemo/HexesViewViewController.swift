//
//  HexesViewViewController.swift
//  Hex
//
//  Created by Christian Otkjær on 26/07/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit
import Hex

class HexesViewViewController: UIViewController
{
    var shape : HexMapShape = HexMapShape.rectangle(width: 5, height: 5)
        {
        didSet
        {
            childHexMapViewController?.map = HexMap<Bool>(shape: shape, repeatedValue: true)
            
            //                childHexMapViewController?.hexes = shape.hexes
        }
    }
    
    @IBOutlet weak var hexesView: HexesView?
    
    override func addChildViewController(_ childController: UIViewController)
    {
        super.addChildViewController(childController)
        
        guard let hexMapViewController = childController as? HexMapViewController else { return }

        hexMapViewController.map = HexMap<Bool>(shape: shape, repeatedValue: true)

        hexMapViewController.collectionView?.allowsMultipleSelection = true
        
        hexMapViewController.delegate = self
    }
    
    var childHexMapViewController : HexMapViewController?
    {
        return childViewControllers.cast(HexMapViewController.self).first
    }
}

// MARK: - HexMapViewControllerDelegate

extension HexesViewViewController : HexMapViewControllerDelegate
{
    func hexMapController(_ controller: HexMapViewController, didSelectHex hex: Hex)
    {
        controller.reloadCellFor(hex: hex)

        guard let hexView = hexesView?.addHex(hex) else { return }
        
        hexView.backgroundColor = UIColor.purple
        hexView.borderSize = 2
        hexView.borderColor = UIColor.orange
    }
    
    func hexMapController(_ controller: HexMapViewController, didDeselectHex hex: Hex)
    {
        controller.reloadCellFor(hex: hex)
        
        hexesView?.removeHex(hex)
    }
}
