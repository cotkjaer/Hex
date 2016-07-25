//
//  RhombusViewController.swift
//  Hex
//
//  Created by Christian Otkjær on 22/07/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit
import Hex
import UserInterface

class RhombusViewController: HexMapShapeViewController
{
    var columns : Int = 4
        {
        didSet { updateShape() }
    }
    
    var rows : Int = 4
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
        shape = .Rhombus(columns: columns, rows: rows)
    }
    
    @IBOutlet weak var columnsSlider: Slider?
        {
        didSet { columnsSlider?.delegate = self }
    }
    
    @IBOutlet weak var rowsSlider: Slider?
        {
        didSet { rowsSlider?.delegate = self }
    }
    
}

// MARK: - SliderDelegate

extension RhombusViewController : SliderDelegate
{
    func sliderDidSlide(slider: Slider) {
        //NOOP
    }
    
    func sliderDidEndSliding(slider: Slider)
    {
        if slider == rowsSlider
        {
            rows = slider.intValue
        }
        else if slider == columnsSlider
        {
            columns = slider.intValue
        }
    }
}
