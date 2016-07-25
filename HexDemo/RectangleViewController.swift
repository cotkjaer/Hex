//
//  RectangleViewController.swift
//  Hex
//
//  Created by Christian Otkjær on 22/07/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit
import Hex
import UserInterface

class RectangleViewController: HexMapShapeViewController
{
    var width : Int = 4
        {
        didSet { updateShape() }
    }

    var height : Int = 4
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
        shape = .Rectangle(width: width, height: height)
    }
    
    @IBOutlet weak var widthSlider: Slider?
        {
        didSet { widthSlider?.delegate = self }
    }

    @IBOutlet weak var heightSlider: Slider?
        {
        didSet { heightSlider?.delegate = self }
    }
    
}

// MARK: - SliderDelegate

extension RectangleViewController : SliderDelegate
{
    func sliderDidSlide(slider: Slider) {
        //NOOP
    }
    
    func sliderDidEndSliding(slider: Slider)
    {
        if slider == heightSlider
        {
            height = slider.intValue
        }
        else if slider == widthSlider
        {
            width = slider.intValue
        }
    }
}
