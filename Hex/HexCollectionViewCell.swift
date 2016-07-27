//
//  HexCollectionViewCell.swift
//  Hex
//
//  Created by Christian Otkjær on 23/05/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit

@IBDesignable
public class HexCollectionViewCell: UICollectionViewCell
{
    @IBOutlet public weak var textLabel: UILabel?
    @IBOutlet public weak var detailLabel: UILabel?
    
    @IBInspectable
    public var borderWidth : CGFloat = 2
        { didSet { updateHexShape(oldValue != borderWidth) } }
    
    @IBInspectable
    public override var borderColor: UIColor?
        { didSet { updateHexBorder(oldValue != borderColor) } }
    
    private let hexLayer = CAShapeLayer()

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
    
    public override func awakeFromNib()
    {
        super.awakeFromNib()
        setup()
    }
    
    func setup()
    {
        updateHexShape()
        updateHexBorder()
        layer.insertSublayer(hexLayer, atIndex: 0)
    }
    
    public var orientation : HexOrientation = .Horizontal
        {
        didSet { updateHexShape(oldValue != orientation) }
    }
    
    public override var bounds: CGRect
    {
        didSet {  updateHexShape(oldValue != bounds) }
    }
    
    public override var frame: CGRect
    {
        didSet { updateHexShape(oldValue != frame) }
    }
 
    private func updateHexBorder(doUpdate: Bool = true)
    {
        if doUpdate
        {
            hexLayer.strokeColor = borderColor?.CGColor
            hexLayer.lineWidth = borderWidth
            
            setNeedsDisplay()
        }
    }
    
    private func updateHexShape(doUpdate: Bool = true)
    {
        guard doUpdate == true else { return }
        
        let center = bounds.center
        
        let width = bounds.width / orientation.hexWidth
        let height = bounds.height / orientation.hexHeight
        
        let edgeLength = min(width, height)// / 2
        
        func cornerOffset(corner : Int) -> CGPoint
        {
            let angle = π2 *
                (CGFloat(corner) + orientation.startAngle) / 6
            
            return CGPoint(x: edgeLength * cos(angle),
                           y: edgeLength * sin(angle))
        }
        
        let corners = (0..<6).map { center + cornerOffset($0) }
        
        hexLayer.path = closedPath(corners).CGPath
        
        setNeedsDisplay()
    }
    
    // Size
    
    public override func sizeThatFits(size: CGSize) -> CGSize
    {
        return CGPathGetBoundingBox((layer.mask as? CAShapeLayer)?.path).size
    }
    
    // MARK: - IB
    
    public override func prepareForInterfaceBuilder()
    {
        updateHexShape()
    }
    
    // MARK: - Color
    
    public override var backgroundColor: UIColor?
        {
        get
        {
            guard let cgColor = hexLayer.fillColor else { return nil }
            
            return UIColor(CGColor: cgColor)
        }
        set
        {
            hexLayer.fillColor = newValue?.CGColor
        }
    }
}
