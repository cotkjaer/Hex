//
//  HexCollectionViewCell.swift
//  Hex
//
//  Created by Christian Otkjær on 23/05/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit

@IBDesignable
open class HexCollectionViewCell: UICollectionViewCell
{
    @IBOutlet open weak var textLabel: UILabel?
    @IBOutlet open weak var detailLabel: UILabel?
    
    private let hexView = HexView(frame: CGRect.zero)
    
    @IBInspectable
    open var hexBorderWidth : CGFloat
        {
        get
        {
            return hexView.hexBorderWidth
        }
        set
        {
            hexView.hexBorderWidth = newValue
        }
    }
    
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
        backgroundView = hexView
        
        setNeedsLayout()
    }
    
    open var orientation : HexOrientation
        {
        get
        {
            return hexView.orientation
        }
        set
        {
            hexView.orientation = newValue
            setNeedsLayout()
        }
    }
    
    open override func layoutSubviews()
    {
        super.layoutSubviews()
        
        hexView.frame = bounds
    }
    
    // Size
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize
    {
        return hexView.sizeThatFits(size)
    }
    
    // MARK: - IB
    
    open override func prepareForInterfaceBuilder()
    {
        hexView.frame = bounds
    }
    
    // MARK: - Color
    
    open override var backgroundColor: UIColor?
        {
        get
        {
            return hexView.backgroundColor
        }
        set
        {
            hexView.backgroundColor = newValue
        }
    }
    
    @IBInspectable
    open var hexBorderColor: UIColor?
        {
        get
        {
            return hexView.hexBorderColor
        }
        set
        {
            hexView.hexBorderColor = newValue
            setNeedsDisplay()
        }
    }
}

/*
@IBDesignable
open class HexCollectionViewCell: UICollectionViewCell
{
    @IBOutlet open weak var textLabel: UILabel?
    @IBOutlet open weak var detailLabel: UILabel?
    
    @IBInspectable
    open var hexBorderWidth : CGFloat
        {
        get
        {
            return hexLayer.lineWidth / 2
        }
        set
        {
            hexLayer.lineWidth = newValue * 2
            setNeedsDisplay()
        }
    }
    
    private let hexLayer = HexLayer()
    private let maskLayer = HexLayer()
    
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
        
        setNeedsLayout()
    }
    
    open var orientation : HexOrientation
        {
        get
        {
            return hexLayer.orientation
        }
        set
        {
            maskLayer.orientation = newValue
            hexLayer.orientation = newValue
            setNeedsLayout()
        }
    }
    
    open override func layoutSubviews()
    {
        super.layoutSubviews()
        
        maskLayer.frame = bounds
        hexLayer.frame = bounds
    }
    
    // Size
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize
    {
        return ((layer.mask as? CAShapeLayer)?.path!.boundingBox.size)!
    }
    
    // MARK: - IB
    
    open override func prepareForInterfaceBuilder()
    {
        maskLayer.frame = bounds
        hexLayer.frame = bounds
    }
    
    // MARK: - Color
    
    open override var backgroundColor: UIColor?
        {
        get
        {
            guard let cgColor = hexLayer.fillColor else { return nil }
            
            return UIColor(cgColor: cgColor)
        }
        set
        {
            hexLayer.fillColor = newValue?.cgColor
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    open var hexBorderColor: UIColor?
        {
        get
        {
            guard let cgColor = hexLayer.strokeColor else { return nil }
            
            return UIColor(cgColor: cgColor)
        }
        set
        {
            hexLayer.strokeColor = newValue?.cgColor
            setNeedsDisplay()
        }
    }
}
*/
