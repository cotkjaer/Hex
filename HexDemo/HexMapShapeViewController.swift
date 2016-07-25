//
//  HexMapShapeViewController.swift
//  Hex
//
//  Created by Christian Otkjær on 21/07/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit
import Hex
import Collections

class HexMapShapeViewController: UIViewController
{
    var shape : HexMapShape = .Custom(hexes: [])
        {
            didSet
            {
                childHexMapViewController?.map = HexMap<Bool>(shape: shape, repeatedValue: true)
                
//                childHexMapViewController?.hexes = shape.hexes
        }
    }

    var childHexMapViewController : HexMapViewController?
    {
        return childViewControllers.find(HexMapViewController)
    }
    
    
    
}
