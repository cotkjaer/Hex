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
        
        hexView?.borderColor = UIColor.blueColor()
        hexView?.borderSize = 2
    }
    
    @IBAction func handleTap(sender: UITapGestureRecognizer)
    {
        guard sender.state == .Ended else { return }
        
        guard let hexView = hexView else { return }
        
//        let point = sender.locationInView(hexView)
//        
//        if hexView.hitTest(point, withEvent: nil) == hexView
//        {
            UIView.animateWithDuration(0.2, animations: {
                hexView.backgroundColor = UIColor.redColor()
                }, completion: { (completed) in
            
                    UIView.animateWithDuration(0.1) { hexView.backgroundColor = UIColor.whiteColor() }
                    
            })
//        }
    }
    
}
