//
//  HitTestViewController.swift
//  Hex
//
//  Created by Christian Otkjær on 26/07/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit
import Hex

class HitTestViewController: UIViewController
{
    @IBOutlet weak var hexView: HexView?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        hexView?.hexBorderColor = UIColor.blue
        hexView?.hexBorderWidth = 2
    }
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer)
    {
        guard sender.state == .ended else { return }
        
        guard let hexView = hexView else { return }
        
//        let point = sender.locationInView(hexView)
//        
//        if hexView.hitTest(point, withEvent: nil) == hexView
//        {
            UIView.animate(withDuration: 0.2, animations: {
                hexView.backgroundColor = UIColor.red
                }, completion: { (completed) in
            
                    UIView.animate(withDuration: 0.1, animations: { hexView.backgroundColor = UIColor.white }) 
                    
            })
//        }
    }
    
}
