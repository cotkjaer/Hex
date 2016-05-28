//
//  HexView.swift
//  Hex
//
//  Created by Christian Otkjær on 23/05/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit

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
    
    private func updateHexMask(doUpdate: Bool = true)
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
        
        if let maskLayer = layer.mask as? CAShapeLayer
        {
            maskLayer.path = pathForHex()
        }
        else
        {
            let maskLayer = CAShapeLayer()
            maskLayer.path = pathForHex()
            
            layer.mask = maskLayer
        }
        
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
        updateHexMask()
    }
}

