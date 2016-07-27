//
//  HexView.swift
//  Hex
//
//  Created by Christian Otkjær on 23/05/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit
import UserInterface

@IBDesignable
public class HexView: UIView
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
    
    public override func awakeFromNib()
    {
        super.awakeFromNib()
        setup()
    }
    
    func setup()
    {
        updateHexMask()
    }
    
    public var orientation : HexOrientation = DefaultHexOrientation
        {
        didSet { updateHexMask(oldValue != orientation) }
    }
    
    public override var bounds: CGRect
        {
        didSet {  updateHexMask(oldValue != bounds) }
    }
    
    public override var frame: CGRect
        {
        didSet { updateHexMask(oldValue != frame) }
    }
    
    public override var borderSize: CGFloat
    {
        didSet { updateHexBorder(borderSize != oldValue) }
    }
    
    public override var borderColor: UIColor?
    {
        didSet { updateHexBorder(borderColor != oldValue) }
    }
    
    private func updateHexBorder(doUpdate: Bool = true)
    {
        guard doUpdate else { return }
        
        guard borderColor?.alpha > 0.001 && borderSize > 0 else
        {
            borderLayer.removeFromSuperlayer(); return
        }
        
        borderLayer.path = maskLayer.path
        borderLayer.strokeColor = borderColor?.CGColor
        borderLayer.lineWidth = borderSize * 2
        borderLayer.fillColor = nil
        layer.addSublayer(borderLayer)
    }
    
    let borderLayer = CAShapeLayer()
    
    private func updateHexMask(doUpdate: Bool = true)
    {
        guard doUpdate else { return }
        
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
        
        func corners() -> [CGPoint]
        {
            return (0..<6).map {
                return center + cornerOffset($0)
            }
        }
        
        func pathForHex() -> CGPath
        {
            let points = corners()
            
            let path = closedPath(points)
            
            return path.CGPath
        }
        
        maskLayer.path = pathForHex()
        
        updateHexBorder()
        
        setNeedsDisplay()
    }
    
    lazy var maskLayer : CAShapeLayer =
        {
            let maskLayer = CAShapeLayer()
            self.layer.mask = maskLayer
            return maskLayer
    }()
    
    // Size
    
    public override func sizeThatFits(size: CGSize) -> CGSize
    {
        return CGPathGetBoundingBox((layer.mask as? CAShapeLayer)?.path).size
    }
    
    // MARK: - IB
    
    public override func prepareForInterfaceBuilder()
    {
        updateHexMask()
    }
    
    // MARK: - Hittest
    
    public override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView?
    {
        var view = super.hitTest(point, withEvent: event)
        
        if view == self && !isPointInHex(point)
        {
            view = nil
        }
        
        return view
    }
    
    public func isPointInHex(point: CGPoint) -> Bool
    {
        return CGPathContainsPoint(maskLayer.path, nil, point, false)
    }
}

