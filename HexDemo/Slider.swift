//
//  Slider.swift
//  Hex
//
//  Created by Christian Otkjær on 22/07/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit
import UserInterface

protocol SliderDelegate
{
    func sliderDidSlide(slider: Slider)
    
    func sliderDidEndSliding(slider: Slider)
}

class Slider: UISlider
{
    var delegate : SliderDelegate?
    
    var thumbLabel = UILabel()
    
    override var value: Float
        {
        didSet
        {
            updateThumbLabelText()
        }
    }
    
    override func setValue(value: Float, animated: Bool)
    {
        super.setValue(value, animated: animated)
        
        updateThumbLabelText()
    }

    // MARK: - Init
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        updateThumbLabelFrame()
    }
    
    func setup()
    {
        thumbLabel.font = UIFont.systemFontOfSize(UIFont.systemFontSize())
        
        thumbLabel.textColor = UIColor.darkTextColor()
        
        thumbLabel.textAlignment = .Center
        
        updateThumbLabelText()
        
        addSubview(thumbLabel)
        
        addTarget(self, action: #selector(Slider.sliderDidSlide), forControlEvents: UIControlEvents.ValueChanged)
        
        let touchUpEvents : UIControlEvents = [UIControlEvents.TouchUpInside, UIControlEvents.TouchUpOutside]
        
        addTarget(self, action: #selector(Slider.sliderDidEndSliding), forControlEvents: touchUpEvents)
    }

    var intValue : Int { return Int(value.round) }
    
    func updateThumbLabelText()
    {
        let text = String(intValue)
        
        if text != thumbLabel.text
        {
            thumbLabel.text = text
        }
    }

    func updateThumbLabelFrame()
    {
        bringSubviewToFront(thumbLabel)
        frameViewOnThumb(thumbLabel)
    }
    
    func sliderDidSlide()
    {
        delegate?.sliderDidSlide(self)
    }
    
    func sliderDidEndSliding()
    {
        setValue(value.round, animated: true)

        delegate?.sliderDidEndSliding(self)
    }
}
