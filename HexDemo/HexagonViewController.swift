//
//  HexagonViewController.swift
//  Hex
//
//  Created by Christian Otkjær on 21/07/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit
import Hex
import UserInterface

class HexagonViewController: ShapeViewController
{
    var radius : Int = 4
        {
        didSet { shape = .hexagon(radius: radius) }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        radius = 4
    }
    
    @IBOutlet weak var radiusSlider: Slider?
        {
        didSet { radiusSlider?.delegate = self }
    }
    
}

// MARK: - SliderDelegate

extension HexagonViewController : SliderDelegate
{
    func sliderDidSlide(_ slider: Slider) {
        //NOOP
    }
    
    func sliderDidEndSliding(_ slider: Slider)
    {
        radius = slider.intValue
    }
}
