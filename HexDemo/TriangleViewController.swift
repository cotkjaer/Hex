//
//  TriangleViewController.swift
//  Hex
//
//  Created by Christian Otkjær on 21/07/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit
import Hex
import UserInterface

class TriangleViewController: ShapeViewController
{
    var size : Int = 4
        {
        didSet { updateShape() }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        updateShape()
    }
    
    func updateShape()
    {
        shape = .triangle(size: size)
    }
    
    @IBOutlet weak var sizeSlider: Slider?
        {
        didSet { sizeSlider?.delegate = self }
    }
    
}

// MARK: - SliderDelegate

extension TriangleViewController : SliderDelegate
{
    func sliderDidSlide(_ slider: Slider) {
        //NOOP
    }
    
    func sliderDidEndSliding(_ slider: Slider)
    {
        size = slider.intValue
    }
}
