//
//  HexView.swift
//  Hex
//
//  Created by Christian Otkjær on 23/05/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit
import UserInterface

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


@IBDesignable
open class HexView: UIView
{
    // MARK: - Init
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    open override func awakeFromNib()
    {
        super.awakeFromNib()
        setup()
    }
    
    func setup()
    {
        layer.insertSublayer(hexLayer, at: 0)
        layer.mask = maskLayer
        hexLayer.fillColor = nil
        
        updateHexMask()
    }
    
    open var orientation : HexOrientation = DefaultHexOrientation
        {
        didSet { updateHexMask(oldValue != orientation) }
    }
    
    open override var bounds: CGRect
        {
        didSet {  updateHexMask(oldValue != bounds) }
    }
    
    open override var frame: CGRect
        {
        didSet { updateHexMask(oldValue != frame) }
    }
    
    public var hexBorderWidth: CGFloat = 0
    {
        didSet { updateHexLayer(hexBorderWidth != oldValue) }
    }
    
    open var hexBorderColor: UIColor? = nil
    {
        didSet { updateHexLayer(hexBorderColor != oldValue) }
    }
    
    private func updateHexLayer(_ doUpdate: Bool = true)
    {
        guard doUpdate else { return }
        
        maskLayer.frame = bounds
        
        hexLayer.frame = bounds
        hexLayer.strokeColor = hexBorderColor?.cgColor
        hexLayer.lineWidth = hexBorderWidth * 2
    }
    
    fileprivate func updateHexMask(_ doUpdate: Bool = true)
    {
        guard doUpdate else { return }

        maskLayer.frame = bounds
        
        updateHexLayer()
        
        setNeedsDisplay()
    }
    
    private let hexLayer = HexLayer()
    
    private let maskLayer = HexLayer()
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize
    {
        return ((layer.mask as? CAShapeLayer)?.path!.boundingBox.size)!
    }
    
    // MARK: - IB
    
    open override func prepareForInterfaceBuilder()
    {
        updateHexMask()
    }
    
    // MARK: - Hittest
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView?
    {
        var view = super.hitTest(point, with: event)
        
        if view == self && !isPointInHex(point)
        {
            view = nil
        }
        
        return view
    }
    
    open func isPointInHex(_ point: CGPoint) -> Bool
    {
        return maskLayer.path?.contains(point) == true
    }
}

